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
  user_sessions = client.page_views(opts[:user], {:start_time=>opts[:start],:end_time=>opts[:end]}).all_pages!.to_a
  map_sessions(user_sessions, client, opts)
end

def map_sessions(user_sessions, client, opts)
  puts "Mapping user sessions..."
  sessions = []

  user_sessions.each do |id|
    session = {}
    session[:session_id]          = id["session_id"]
    session[:url]                 = id["url"]
    session[:conteodt_type]        =id["context_type"]
    session[:interaction_seconds] = id["interaction_seconds"]
    session[:created_at]          = id["created_at"]
    session[:updated_at]          = id["updated_at"]
    session[:render_time]         = id["render_time"]
    session[:user_agent]          = id["user_agent"]
    session[:participated]        = id["participated"]
    session[:http_method]         = id["http_method"]
    session[:remote_ip]           = id["remote_ip"]
    session[:id]                  = id["id"]
    sessions << session
  end
  to_csv(sessions, opts)
end

def to_csv(sessions, opts)
  puts "Writing to csv..."
  response = sessions.first

  CSV.open("#{opts[:domain]}_user-#{opts[:user]}.csv", "wb") do |csv|
      csv << response.keys
    sessions.each do |column|
      csv << column.values
    end
  end
end 
fetch_sessions(url, opts)