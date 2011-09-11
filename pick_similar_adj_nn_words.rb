
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
	has_many :disco_frames
end

class DiscoOccurrence < ActiveRecord::Base
	set_table_name "disco_occurrences"
	belongs_to :disco_data
	validates_uniqueness_of :sentence, :scope => :disco_data_id
end

class DiscoFrame < ActiveRecord::Base
	set_table_name "disco_frames"
	belongs_to :disco_data
end


class Headword < ActiveRecord::Base
	has_many :sim_sets
end

class SimSet < ActiveRecord::Base
	set_table_name "sim_sets"
	belongs_to :headword

end


data = DiscoData.find(:all, :conditions => ["set_id = 3 and syntactic = 'EN_ADJ_NN'"], :group => "w1, w2")


for item in data
	set = Headword.find(:first, :conditions => ["word = ?", item.w2])
	if set.nil?
		puts "-" * 5 + "> " + item.w2
		next
	end

	replacing_word = 2
	for word in set.sim_sets.find(:all, :limit => "25")
		break if word.word.include?(")")
		temp = DiscoFrame.new
		temp.disco_data_id = item.id
		temp.w =  word.word.strip.gsub("C_","").downcase
		temp.replacing_word = replacing_word
		temp.save
		puts "mmmm"
	end

	set = Headword.find(:first, :conditions => ["word = ?", item.w1])
        if set.nil?
                puts "-" * 5 + "> " + item.w1
                next
        end

        replacing_word = 1
        for word in set.sim_sets.find(:all, :limit => "25")
                break if word.word.include?(")")
                temp = DiscoFrame.new
                temp.disco_data_id = item.id
                temp.w =  word.word.strip.gsub("C_","").downcase
                temp.replacing_word = replacing_word
                temp.save
		puts "nnnnn"
        end



end



