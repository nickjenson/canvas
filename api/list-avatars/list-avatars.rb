require 'slop'
require 'yaml'
require 'bearcat'
require 'ruby-progressbar'
require 'csv'

env = ''
version = '0.0.2'
script = 'list-avatars.rb'

opts = Slop.parse do |opts|
  opts.banner = 'Usage: script.rb [options]'
  opts.string '-t', '--token', 'api token'
  opts.string '-d', '--domain', 'domain'
  opts.string '-c', '--client', 'client.yaml' do
    yaml = "#{opts[:client]}/#{opts[:client]}.yaml"
    opts = load_file(yaml)
    raise 'Client does not exist!' unless File.exist?(yaml)
  end
  opts.on '-h', '--help', 'help' do
    puts "#{script} v.#{version}", opts
    exit
  end
end

env != '' ? env << '.' : env
url = "https://#{opts[:domain]}.#{env}instructure.com"

if [opts[:domain], opts[:token]].any?(&:nil?)
  raise 'Error: Missing one or more required fields'
end

def fetch_users(url, opts)
  puts 'Fetching users...'
  client = Bearcat::Client.new(token: opts[:token], prefix: url)
  all_users = client.list_users('self').all_pages!.to_a
  user_ids = []

  all_users.each do |user|
    user_ids << user['id']
  end
  fetch_avatar_urls(client, user_ids, opts)
end

def fetch_avatar_urls(client, user_ids, opts)
  puts "Mapping user avatars..."
  progressbar = ProgressBar.create(format: '%e <%B> %p%% %t', total: user_ids.count)
  users_with_avatars = []

  user_ids.each do |id|
    id = client.user_profile(id)
    user = {}
    user[:id]          = id['id']
    user[:name]        = id['name']
    user[:short_name]  = id['short_name']
    user[:sis_user_id] = id['sis_user_id']
    user[:avatar_url]  = id['avatar_url']
    users_with_avatars << user
    progressbar.increment
  end
  print_to_csv(users_with_avatars, opts)
end

def print_to_csv(users_with_avatars, opts)
  puts 'Writing to CSV...'
  response = users_with_avatars.first

  CSV.open("#{opts[:domain]}-avatars.csv", 'wb') do |csv|
    csv << response.keys
    users_with_avatars.each do |column|
      csv << column.values
    end
  end
end
fetch_users(url, opts)
