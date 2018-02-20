require 'csv'
require 'typhoeus'

### CHANGE THESE VALUES
domain = '' # e.g. 'domain' in 'https://domain.instructure.com'
token = ''  # api token for account admin user
csv = 'users.csv'

#================
# Don't edit from here down unless you know what you're doing.

env != '' ? env << '.' : env
base_url = "https://#{domain}.instructure.com"
test_url = "#{base_url}/accounts/self"

raise "Error: can't locate the update CSV" unless File.exist?(csv)


test = Typhoeus.get(test_url, followlocation: true)
raise "Error: The token, domain, or env variables are not set correctly" unless test.code == 200

CSV.foreach(csv, {:headers => true}) do |row|
  url = "#{base_url}/api/v1/accounts/self/users"

  create_user = Typhoeus.post(url,
    headers: { :authorization => 'Bearer ' + token },
    body: {
      user: {
        :name => row['first_name'] + ' ' + row['last_name']
      },
      pseudonym: {
        :unique_id => row['login_id'],
        :sis_user_id => row['user_id'],
        :force_self_registration => true
      },
      communication_channel: {
        :address => row['email']
      }
    })
  if create_user.code == 200
    puts "User #{row['user_id']} has been created."
  elsif create_user.code == 400
    puts "Error: #{row['user_id']} had not been created. User login_id already in user for this account and authentication provider."
  else
    puts "User #{row['user_id']} had failed to be created."
    puts "Moving right along..."
  end
end
puts "Finished creating users with a forced self-registration option."