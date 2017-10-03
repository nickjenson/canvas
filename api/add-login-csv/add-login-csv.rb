require 'typhoeus'
require 'csv'
require 'json'

### CHANGE THESE VALUES
@domain = ''  # e.g. 'domain' in 'https://domain.instructure.com'
@token = ''   # api token for account admin user
@env = ''     # leave blank for production, or use test or beta.
@csv = 'add-login-csv.rb' 
@root = 'self'
# =======================
# Do not edit from here unless you know what you're doing.

@env != '' ? @env << '.' : @env
@base_url = "https://#{@domain}.#{@env}instructure.com/api/v1"


CSV.foreach(@csv, {headers: true}) do |row|

  if row['canvas_user_id'].nil?
    puts 'No data in needed canvas_user_id column'
    raise 'Valid CSV headers not found (Expecting canvas_user_id)'

  elsif row['login_id'].nil?
    puts 'No data in needed login_id csv column'
    raise 'Valid CSV headers not found (Expecting login_id)'

  elsif row['authentication_provider_id'].nil?
    puts 'No data in needed authentication_provider_id csv column'
    raise 'Valid CSV headers not found (Expecting authentication_provider_id)'

  elsif row['sis_user_id'].nil?
    puts 'No data in needed sis_user_id csv column'
    raise 'Valid CSV headers not found (Expecting sis_user_id)'
  else
    canvas_user_id = row['canvas_user_id']
    login_id = row['login_id']
    authentication_provider_id = row['authentication_provider_id']
    sis_user_id = row['sis_user_id']
    response = Typhoeus.put
      (
      @base_url + "api/v1/accounts/" + @root + "/logins/",
      headers: {
        :authorization => 'Bearer ' + @token , 'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        user: {
          :id => canvas_user_id
          },
          login: {
            :unique_id => login_id,
            :authentication_provider_id => authentication_provider_id,
            :sis_user_id => sis_user_id
          }
        }
      )
    #parse JSON data to save in readable array
    data = JSON.parse(response.body)
    puts data
  end
end