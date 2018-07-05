require 'csv'
require 'typhoeus'

### CHANGE THESE VALUES
domain = ''           # ex. 'domain' in 'https://domain.instructure.com'
token = ''            # api token for account admin user
feature = ''          # ex. new_gradebook
status = 'on'         # use 'off' to disable feature
csv = 'courses.csv'   # this should contain a canvas_course_id header
#================
base_url = "https://#{domain}.instructure.com"
test_url = "#{base_url}/accounts/self"
raise "Error: can't locate the update CSV" unless File.exist?(csv)

test = Typhoeus.get(test_url, followlocation: true)
raise "Error: The token, domain, or env variables are not set correctly" unless test.code == 200

CSV.foreach(csv, {:headers => true}) do |row|
  url = "#{base_url}/api/v1/courses/#{row['canvas_course_id']}/features/flags/#{feature}?status=#{status}"

  update_flag = Typhoeus.post(url, headers: { :authorization => 'Bearer ' + token })

  if update_flag.code == 200    #aw hell ya
    puts "Course #{row['canvas_course_id']} has feature flag now nabled."
  elsif update_flag.code == 400 #aw hell no - check the url, domain or token
    puts "Error: 400 - that's a bad request for #{row['canvas_course_id']}."
  else
    puts "Course #{row['canvas_course_id']} had failed to enable feature flag."
    puts "Moving right along..." #aw hell no - something else is up
  end
end
puts "Well...\nit's done - for better or for worse\n\n"