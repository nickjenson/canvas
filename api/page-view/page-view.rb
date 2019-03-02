require "slop"
require "yaml"
require "bearcat"
require "csv"

env = ""
version = "0.0.3"
script = "page-view.rb"

opts = Slop.parse do |opts|
  opts.banner  = "Usage: script.rb [options]"
  opts.string "-t", "--token", "api token"
  opts.int "-u", "--user", "canvas user"
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

unless (opts[:start] || opts[:end]).match(/^\d\{1,2}\-\d\{1,2}\-\d\{4}/)
 raise "Error: Date format invalid"
end

# TODO raise "Error: invalid domain or token" unless response.code == 200

def fetch_sessions(url, opts)
  puts "Fetching user sessions..."
  client = Bearcat::Client.new(token: opts[:token], prefix: url)
  page_views = client.page_views(opts[:user]).all_pages!.to_a

  sessions = []
  page_views.each do |session|
   sessions << session['session_id']
  end
  map_sessions(page_views, opts)
end

def map_sessions(page_views, opts)
  puts "Mapping user sessions..."
  user_sessions = []

  session = {}
  page_views.each do |id|
    session[:session_id]          = id["session_id"]
    session[:url]                 = id["url"]
    session[:context_type]        = id["context_type"]
    session[:interaction_seconds] = id["interaction_seconds"]
    session[:created_at]          = id["created_at"]
    session[:updated_at]          = id["updated_at"]
    session[:render_time]         = id["render_time"]
    session[:user_agent]          = id["user_agent"]
    session[:participated]        = id["participated"]
    session[:http_method]         = id["http_method"]
    session[:remote_ip]           = id["remote_ip"]
    session[:id]                  = id["id"]
    end
    user_sessions << session

  to_csv(user_sessions, opts)
end

def to_csv(user_sessions, opts)
  puts "Writing to csv..."
  response = user_sessions.first

  CSV.open("#{opts[:domain]}_user-#{opts[:user]}.csv", "wb") do |csv|
      csv << response.keys
    user_sessions.each do |column|
      csv << column.values
    end
  end
end 
fetch_sessions(url, opts)