# set_course_grading_scheme.rb
require 'csv'
require 'typhoeus'

### CHANGE THESE VAlUES
domain = 'nickjenson'
token  = '6618~3wHWkW6g8ztcRiIm6aYHuuAZmmcDQIOqIuwawKBGaY0DYZZKx8YDoBT3P7wwFVaU'
csv    = 'courses.csv'
grading_standard  = '1091'
#=====================

base_url = "https://#{domain}.instructure.com/"
test_url = "#{base_url}/accounts/self"
raise "Error: can't locate the update CSV" unless File.exist?(csv)

test = Typhoeus.get(test_url, followlocation: true)
raise "Error: the token, domain or env variables are not set correctly" unless test.code == 200

CSV.foreach(csv, {:headers => true}) do |row|
  url = "#{base_url}api/v1/courses/#{row['canvas_course_id']}"

  set_scheme = Typhoeus.put(url, 
      headers: { :authorization => 'Bearer ' + token },
      params:  { 'course[grading_standard_id]' => grading_standard })

  if set_scheme.code == 200 #aw hell ya
    puts "Success! Grading scheme set for course #{row['canvas_course_id']}"
  elsif set_scheme.code == 400 #aw hell no - check the url, domain or token
    puts "Error: 400 - that's a bad request for course #{row['canvas_course_id']}"
  else
    puts "Error: failed to set grading scheme for course #{row['canvas_course_id']}"
    puts "Moving right along..."
  end
end
puts "Well...\nit's done - for better or for worse\n\n"