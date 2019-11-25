#!/usr/bin/env ruby
require 'slop'
require 'csv'

version = '0.0.1'
script = 'split-csv.rb'

itemcount = 0
filecount = 1

opts = Slop.parse do |opts|
  opts.banner = 'Usage: script.rb [options]'
  opts.string  '-f', '--file',  'path to csv file'
  opts.integer '-m', '--max',   'max item count per split file'
  opts.on '-h', '--help', 'help' do
    puts "#{script} v.#{version}", opts
    exit
  end
end

#set defaults if not set through option-parser
opts[:file] ||= 'original.csv'
opts[:max] ||= 20000

#raise for missing/invalid files
raise "Error: Missing #{opts[:file]}, no alternate file provided. Use -h for help." unless File.exist?(opts[:file])
raise "Error: Invalid file. Please provide a valid csv file. Use -h for help." unless opts[:file] =~ /^.+\.csv\b/

#read file, set xpath
csv = CSV.read(opts[:file], col_sep: ';') 

#create directory
time = Time.now.utc.strftime("%m%d%H%M")
dir  = "csv-split-#{time}"
Dir.mkdir(dir) unless Dir.exist?(dir)

#open first csv-export file
puts "Writing #{dir}/csv-split-#{filecount}.csv"
headers = "ProcessId,SourceSystem,SourceSystemComponent,ProcessStatusId,ProcessStartDate,ProcessEndDate,BiztalkMessage"
file = File.open("#{dir}/csv-split-#{filecount}.csv", "w")
file.puts headers

#write each lineitem to file if < max-items
csv.each do |item|
	if itemcount < opts[:max]
		item.each do |column|
			file.print column << ","
		end
		file.print "\n"
		itemcount += 1
	# if == max-items, close csv file, create new file, reset count for new file
	elsif itemcount == opts[:max]
		file.close
    filecount += 1
		if filecount > 0
			puts "Writing #{dir}/csv-split-#{filecount}.csv"
			file = File.new("#{dir}/csv-split-#{filecount}.csv", "w")
			file.puts headers
			itemcount = 0
		end
	end
end