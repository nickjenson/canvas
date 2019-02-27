require "slop"
require "yaml"
require "bearcat"
require "csv"
require "json"
require "byebug"

env = ""
version= "0.0.1"
script = "page-view.rb"

options = {}
opts = Slop.parse do |opts|
  opts.banner  = "Usage: script.rb [options]"
  opts.string "-t", "--token", "api token"
  opts.string "-u", "--user", "canvas user"
  opts.string "-c", "--client", "client.yaml"
  opts.string "-d", "--domain", "domain"
  opts.string "-s", "--start", "start date"
  opts.string "-e", "--end", "end date" 
  opts.on "-h", "--help", "help" do
    puts "#{script} v.#{version}", opts
    exit
  end
end

env != "" ? env << "." : env
url = "https://#{opts[:domain]}.#{env}instructure.com"

user_id = opts[:user]

def fetch_user(url, opts, user_id)
  puts 'Fetching user page views...'

  client = Bearcat::Client.new(token: opts[:token], prefix: url)
  page_views = client.page_views(user_id).all_pages!.to_a

  if page_views.nil?
    raise "Nope"
  end
  to_csv(page_views, opts, user_id)
end

def to_csv(page_views, opts, user_id)
  puts "Writing to csv..."

  CSV.open("#{opts[:domain]}_user-#{user_id}.csv", "w") do |csv|
    page_views.each do |row|
      csv << row.values
    end
  end

end 
fetch_user(url, opts, user_id)


# unless File.directory?(opts[:client]).nil? do |yaml|
#   #todo optional client.yaml
#   # if File.exists?("#{opts[:client]}.yaml")
#   #   coptions = YAML::load_file("#{opts[:client]}.yaml")
#   #   puts coptions
#   #   options = options.merge(coptions)
#   # else
#   #     (puts "ERROR: Client does not exist!")
#   # end
# end

# raise "Error: only provide the subdomain - (ex. example for example.instructure.com)" unless opts[:domain].match(/^[\w\-]+$/)
# raise "Error: user" unless opts[:user].match(/^\d+$/)
# raise "Error: token" unless opts[:token].match(/^(\d{2,}+~)+\d{10,}+$/)
# raise "Error: start date required" unless opts[:start].match(/^\d\{1,2}\-\d\{1,2}\-\d\{4}/)