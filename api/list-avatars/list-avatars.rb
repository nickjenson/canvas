require 'csv'
require 'json'
require 'bearcat'
require 'typhoeus'
require 'ruby-progressbar'

### CHANGE THESE VALUES

domain = '' # e.g. 'domain' in 'https://domain.instructure.com'
token = '' # api token for account admin user
env = '' # leave blank for production, or use test or beta.

# =======================
# Do not edit from here unless you know what you're doing.

env != '' ? env << '.' : env
base_url = "https://#{domain}.#{env}instructure.com"

def fetch_users(base_url, token, domain)
  puts 'Fetching users...'

  client = Bearcat::Client.new(token: token, prefix: base_url)
  all_users = client.list_users('self').all_pages!.to_a

  user_ids = []
  all_users.each do |user|
    user_ids << user['id']
  end
  fetch_avatar_urls(client, user_ids, domain)
end

def fetch_avatar_urls(client, user_ids, domain)
  progressbar = ProgressBar.create(total: user_ids.count)
  users_with_avatars = []

  user = {}
  user_ids.each do |id|
    x = client.user_profile(id)
    user[:id]          = x['id']
    user[:name]        = x['name']
    user[:short_name]  = x['short_name']
    user[:sis_user_id] = x['sis_user_id']
    user[:avatar_url]  = x['avatar_url']
    users_with_avatars << x

    progressbar.increment
  end

  puts 'Preparing CSV...'
  print_to_csv(users_with_avatars, domain)
end

def create_csv(domain)
  headers = "id,name,short_name,sis_user_id,avatar_url\n"

  File.open("./#{domain}_avatar-list.csv", 'w'){ |x| x.write(headers) }
end

def print_to_csv(users, domain)
  headers = %w[]
  users.each do |user|
    CSV.open("./#{domain}_avatar-list.csv", 'a') do |csv|
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

create_csv(domain)
fetch_users(base_url, token, domain)