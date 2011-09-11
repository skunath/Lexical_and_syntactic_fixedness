
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
	:adapter => "mysql2",
	:host => "localhost",
	:username => "lex_mini_project",
	:password => "lex-project",
	:database => "lex_mini_project",
	:encoding => "utf8"
)

class DiscoData < ActiveRecord::Base
	set_table_name "disco_data"
	has_many :disco_occurrences
end

class DiscoOccurrence < ActiveRecord::Base
	set_table_name "disco_occurrences"
	belongs_to :disco_data
	validates_uniqueness_of :sentence, :scope => :disco_data_id

end


class DiscoParse < ActiveRecord::Base
	set_table_name "disco_parses"
end


data = DiscoParse.find(:all, :conditions => "complexity_calc is null", :limit => 25)

while !data.nil?
begin 
for item in data 
	tree = ""
	for line in item.parse.split("\n")
		break if line.strip == ""
		tree += line.strip
	end

	item.complexity_calc = tree.count("(")
	item.save
end
end
data = DiscoParse.find(:all, :conditions => "complexity_calc is null", :limit => 25)
end

