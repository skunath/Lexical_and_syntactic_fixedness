
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


data = DiscoOccurrence.find(:all, :conditions => "sentence_length is null", :limit => 25)

alpha = ("a".."z").to_a

while data.size > 0
begin 
for item in data 
	numword = 0
	sent = item.sentence.split()
	for word in sent
		iword = word.split("/")
		if !iword[0][0].nil?
		numword += 1 if alpha.include?(iword[0][0].downcase)
		end 
	end
	item.sentence_length = numword
	item.save
end
end
data = DiscoOccurrence.find(:all, :conditions => "sentence_length is null", :limit => 25)

end

