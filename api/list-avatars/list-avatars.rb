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
  progressbar = ProgressBar.create(total: user_ids.count)
  users_with_avatars = []

  user = {}
  user_ids.each do |id|
    id = client.user_profile(id)
    user[:id]          = id['id']
    user[:name]        = id['name']
    user[:short_name]  = id['short_name']
    user[:sis_user_id] = id['sis_user_id']
    user[:avatar_url]  = id['avatar_url']
    users_with_avatars << id
    progressbar.increment
  end
  puts 'Preparing CSV...'
  print_to_csv(users_with_avatars, opts)
end

def print_to_csv(users_with_avatars, opts)
  headers = %w[]
  CSV.open("./#{opts[:domain]}_avatar-list.csv", 'wb') do |csv|
  users_with_avatars.each do |user|
      row = CSV::Row.new(headers, [])
      row['id']              = user['id']
      row['name']            = user['name']
      row['short_name']      = user['short_name']
      row['sis_user_id']     = user['sis_user_id']
      row['avatar_url']      = user['avatar_url']
      csv << row
    end
  end
  puts 'Done'
end
fetch_users(url, opts)