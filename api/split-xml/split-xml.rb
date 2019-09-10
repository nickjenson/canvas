#!/usr/bin/env ruby
require 'slop'
require 'nokogiri'

version = '0.0.1'
script = 'split-xml.rb'

itemcount = 0
filecount = 1

opts = Slop.parse do |opts|
  opts.banner = 'Usage: script.rb [options]'
  opts.string  '-x', '--xpath', 'xpath to lineitem'
  opts.string  '-f', '--file',  'path to xml file'
  opts.integer '-m', '--max',   'max item count per export'
  opts.on '-h', '--help', 'help' do
    puts "#{script} v.#{version}", opts
    exit
  end
end

#set defaults if not set through option-parser
opts[:xpath] ||= '//bdems:transactionRecord'
opts[:file] ||= 'original.xml'
opts[:max] ||= 20000

#raise for missing/invalid files
raise "Error: Missing #{opts[:file]}, no alternate file provided. Use -h for help." unless File.exist?(opts[:file])
raise "Error: Invalid file. Please provide a valid xml file. Use -h for help." unless opts[:file] =~ /^.+\.xml\b/

#read file, set xpath
file_contents = File.read(opts[:file])
data = Nokogiri::XML(file_contents)
lineitem = data.xpath('//bdems:transactionRecord')

#create directory
time = Time.now.utc.strftime("%m%d%H%M")
dir  = "xml-split-#{time}"
Dir.mkdir(dir) unless Dir.exist?(dir)

#open first xml-export file
puts "Writing #{dir}/xml-split-#{filecount}.xml"
xmltag = "<?xml version=\"1.0\"?>\n<bdems:bulkDataRecord xmlns:bdems=\"http://www.imsglobal.org/services/lis/bdemsv1p0/imsbdemsFileData_v1p0\">"
file = File.open("#{dir}/xml-split-#{filecount}.xml",'w')
file.puts xmltag

#write each lineitem to file if < max-items
lineitem.each do |item|
	if itemcount < opts[:max]
		file.puts item
		itemcount += 1
	#if == max-items, close xml file, create new file, reset count for new file
	elsif itemcount == opts[:max]
		file.puts '</bdems:bulkDataRecord>'
		file.close
		filecount += 1
		if filecount > 0
			puts "Writing #{dir}/xml-split-#{filecount}.xml"
			file = File.new("#{dir}/xml-split-#{filecount}.xml", "w")
			file.puts xmltag
			itemcount = 0
		end
	end
end