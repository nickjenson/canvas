require "slop"
require "yaml"
require "bearcat"
require "csv"

env = ""
version = "1.0.0"
script = "page-view.rb"

opts = Slop.parse do |opts|
  opts.banner  = "Usage: script.rb [options]"
  opts.string "-t", "--token", "api token"
  opts.string "-u", "--user", "canvas user"
  opts.string "-d", "--domain", "domain"
  opts.string "-s", "--start", "start date"
  opts.string "-e", "--end", "end date"
  opts.string "-c", "--client", "client.yaml" do |client|
    raise "Client does not exist!" unless File.exists?("#{client}/#{client}.yaml")
    opts = YAML::load_file("#{client}/#{client}.yaml")
  end
  opts.on "-h", "--help", "help" do
    puts "#{script} v.#{version}", opts
    exit
  end
end

env != "" ? env << "." : env
url = "https://#{opts[:domain]}.#{env}instructure.com"

raise "Error: Missing one or more required fields" if [opts[:domain], opts[:token], opts[:user], opts[:start]].any?(&:nil?)

unless (opts[:start] || opts[:end]).match(/^\d{4}-\d{2}-\d{2}$/)
  raise "Error: Date format invalid"
end

def fetch_sessions(url, opts)
  puts "Fetching user sessions..."
  client = Bearcat::Client.new(token: opts[:token], prefix: url)
  page_views = client.page_views(opts[:user], {:start_time=>opts[:start],:end_time=>opts[:end]}).all_pages!.to_a
  map_requests(page_views, opts)
end

def map_requests(page_views, opts)
  puts "Mapping user requests..."
  requests = []

  page_views.each do |id|
    request = {}
    request[:session_id]          = id["session_id"]
    request[:url]                 = id["url"]
    request[:context_type]        = id["context_type"]
    request[:interaction_seconds] = id["interaction_seconds"]
    request[:created_at]          = id["created_at"]
    request[:updated_at]          = id["updated_at"]
    request[:render_time]         = id["render_time"]
    request[:user_agent]          = id["user_agent"]
    request[:participated]        = id["participated"]
    request[:http_method]         = id["http_method"]
    request[:remote_ip]           = id["remote_ip"]
    request[:id]                  = id["id"]
    requests << request
  end
  to_csv(requests, opts)
end

def to_csv(requests, opts)
  puts "Writing to csv..."
  response = requests.first

  CSV.open("#{opts[:domain]}_user-#{opts[:user]}.csv", "wb") do |csv|
    csv << response.keys
    requests.each do |column|
      csv << column.values
    end
  end
end 
fetch_sessions(url, opts)