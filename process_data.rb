
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
	:adapter => "mysql2",
	:host => "localhost",
	:username => "lex_mini_project",
	:password => "lex-project",
	:database => "lex_mini_project"
)

class DiscoData < ActiveRecord::Base
	set_table_name "disco_data"
end


$basedir = "/home/sak68/lex-project/data/all_eng/"

files = Dir.glob($basedir + "*")
types = ["low", "medium", "high"]


for input_file in files
	open_file = File.open(input_file, "r")
	training = 0
	training = input_file.index("train")
	set = 1
	if !training.nil?
		set = 2
	end
	
	
	for line in open_file
		temp_line = line.strip().split()
		
		new_row = DiscoData.new()
		new_row.syntactic = temp_line[0]
		new_row.w1 = temp_line[1]
		new_row.w2 = temp_line[2]
		new_row.set_id = set
		
		if types.include?(temp_line[3].strip())
			new_row.coarse = temp_line[3].strip()
		else
			new_row.numeric_score = temp_line[3].strip()
		end	
	
		new_row.save

	end


end


