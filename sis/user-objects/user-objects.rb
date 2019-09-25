require 'json'
require 'slop'

version = '0.0.1'
script = 'user-objects.rb'

opts = Slop.parse do |opts|
  opts.banner = 'Usage: script.rb [options]'
  opts.array  '-u', '--user', 'array of users',    delimiter: ',', required: true
  opts.string '-f', '--file', 'path to json file', default: 'original.json'
  opts.string '-o', '--out',  'output file name',  default: 'found-user-objects'
  opts.on '-h', '--help', 'help' do
    puts "#{script} v.#{version}", opts
    exit
  end
end

#raise for missing/invalid files
raise "Error: Missing #{opts[:file]}, no alternate file provided. Use -h for help." unless File.exist?(opts[:file])
raise "Error: Invalid file. Please provide a valid xml file. Use -h for help." unless opts[:file] =~ /^.+\.json\b/


#read file, set users
file_contents = File.read(opts[:file])
data = JSON.parse(file_contents)
outdata = {"accounts"=>[],"courses"=>[],"enrollments"=>[],"sections"=>[],"terms"=>[],"users"=>[]}

course_list = []
section_list = []
account_list = []
term_list = []

#users
data['users'].each do |user|
    if(opts[:user].include?(user['user_id']))
        outdata['users'].push(user)
    end
end

#enrollments (create section_list)
data['enrollments'].each do |enrollment|
    if(opts[:user].include?(enrollment['user_id']))
        outdata['enrollments'].push(enrollment)
        unless(section_list.include?(enrollment['section_id']))
			section_list.push(enrollment['section_id'])
		end
    end
end

#sections (create course_list)
data['sections'].each do |section|
    if(section_list.include?(section['section_id']))
        outdata['sections'].push(section)
        unless(course_list.include?(section['section_id']))
			course_list.push(section['course_id'])
		end
    end
end

#courses (create account_list/create term_list)
data['courses'].each do |course|
    if(course_list.include?(course['course_id']))
        outdata['courses'].push(course)
        unless(account_list.include?(course['account_id']))
        	account_list.push(course['account_id'])
        end
        unless(term_list.include?(course['term_id']))
        	term_list.push(course['term_id'])
        end
    end
end

#accounts
data['accounts'].each do |account|
    if(account_list.include?(account['account_id']))
        outdata['accounts'].push(account)
    end
end

#terms
data['terms'].each do |term|
    if(term_list.include?(term['term_id']))
        outdata['terms'].push(term)
    end
end


File.open("#{opts[:out]}.json",'w') do |file|
    file.write(JSON.pretty_generate(outdata))
end

response = {"counts": {"accounts": "#{outdata['accounts'].length}","courses": "#{outdata['courses'].length}","enrollments": "#{outdata['enrollments'].length}","sections": "#{outdata['sections'].length}","terms": "#{outdata['terms'].length}","users": "#{outdata['users'].length}"}}
puts JSON.pretty_generate(response)