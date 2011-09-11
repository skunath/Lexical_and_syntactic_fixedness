
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


def cqpcommand(i_command)
                begin
                        File.delete("/home/sak68/lex-project/scripts/cqp-rip/temp_command")
                        File.delete("/home/sak68/lex-project/scripts/test")
                rescue
                end
                command = open("./cqp-rip/temp_command", "w")
                command.puts(i_command)
                command.close
                syscommand = "/opt/software/bin/cqp -e -D UKWAC1 -f /home/sak68/lex-project/scripts/cqp-rip/temp_command -p > /home/sak68/lex-project/scripts/test"
                system(syscommand)
                return_count = `wc -l ./test`
                return return_count.strip().to_i
end



data = DiscoData.find(:all, :conditions => ["syntactic = 'EN_V_OBJ'"], :group => "w1, w2")


for item in data
	next if item.disco_frames.nil?
	for replacement in item.disco_frames

	temp_command = "[lemma1=\"replace1\" & pos=\"V.*\"] []{0,2} [lemma2=\"replace2\"];"
	if replacement.replacing_word == 2
		temp_command = temp_command.gsub("lemma2", "word")
		temp_command = temp_command.gsub("replace2", replacement.w)
		temp_command = temp_command.gsub("lemma1", "lemma")
		temp_command = temp_command.gsub("replace1", item.w1)
	else
		temp_command = temp_command.gsub("lemma1", "word")
		temp_command = temp_command.gsub("replace1", replacement.w)
		temp_command = temp_command.gsub("lemma2", "lemma")
                temp_command = temp_command.gsub("replace2", item.w2)
	end
	puts temp_command

	corpus_counts = cqpcommand(temp_command)
	puts corpus_counts
	replacement.corpus_count = corpus_counts
	replacement.save
	end
end



