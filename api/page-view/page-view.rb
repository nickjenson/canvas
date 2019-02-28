require "slop"
require "yaml"
require "bearcat"
require "csv"
require "byebug"

env = ""
version = "0.0.2"
script = "page-view.rb"

options = {}
opts = Slop.parse do |opts|
  opts.banner  = "Usage: script.rb [options]"
  opts.string "-t", "--token", "api token"
  opts.string "-u", "--user", "canvas user"
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
path = "#{opts[:client]}/#{opts[:client]}.yaml"

# raise "Error: only provide the subdomain - (ex. example for example.instructure.com)" unless opts[:domain].match(/^[\w\-]+$/)
# raise "Error: user" unless opts[:user].match(/^\d+$/)
# raise "Error: token" unless opts[:token].match(/^(\d{1,}+~)+\d{10,}+$/)
# raise "Error: start date required" unless opts[:start].match(/^\d\{1,2}\-\d\{1,2}\-\d\{4}/)

def fetch_user(url, opts)
  puts "Fetching user page views..."

  client = Bearcat::Client.new(token: opts[:token], prefix: url)
  page_views = client.page_views(opts[:user]).all_pages!.to_a

  # if page_views.nil?
  #   raise "Nope"
  # end
  to_csv(page_views, opts)
end

def to_csv(page_views, opts)
  puts "Writing to csv..."
  response = page_views.first

  CSV.open("#{opts[:domain]}_user-#{opts[:user]}.csv", "wb") do |csv|
      csv << response.keys

    page_views.each do |column|
      csv << column.values
    end
  end
end 
fetch_user(url, opts)