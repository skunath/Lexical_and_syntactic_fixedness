
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
                        File.delete("/home/sak68/lex-project/scripts/cqp-rip/temp_command2")
                        File.delete("/home/sak68/lex-project/scripts/test2")
                rescue
                end
                command = open("./cqp-rip/temp_command2", "w")
                command.puts(i_command)
                command.close
                syscommand = "/opt/software/bin/cqp -e -D UKWAC1 -f /home/sak68/lex-project/scripts/cqp-rip/temp_command2 -p > /home/sak68/lex-project/scripts/test2"
                system(syscommand)
                return_count = `wc -l ./test2`
                return return_count.strip().to_i
end



data = DiscoData.find(:all, :conditions => ["syntactic = 'EN_ADJ_NN' and averag_complexity is null"], :group => "w1, w2")


for item in data
	temp_command = "[replace1 pos=\"J.*\"] [replace2  pos=\"N.*\"];"
	
	total_count = 0
        w1_fixed_count = 0
        w2_fixed_count = 0

        temp_command = temp_command.gsub("replace1", " word=\"" + item.w1.strip + "\" & ")
        temp_command = temp_command.gsub("replace2", " word=\"" + item.w2.strip + "\" & ")
        puts temp_command
	corpus_counts = cqpcommand(temp_command)
        total_count += corpus_counts
        puts "^" * 3 + corpus_counts.to_s
	corpus_counts = 0

        temp_command = "[replace1 pos=\"J.*\"] [replace2  pos=\"N.*\"];"
        temp_command = temp_command.gsub("replace1", " word=\"" + item.w1.strip + "\" & ")
        temp_command = temp_command.gsub("replace2", "")
        puts temp_command
	corpus_counts = cqpcommand(temp_command)
        w1_fixed_count += corpus_counts
        puts "^" * 3 + corpus_counts.to_s
	corpus_counts = 0

        temp_command = "[replace1 pos=\"J.*\"] [replace2 pos=\"N.*\"];"
        temp_command = temp_command.gsub("replace1", "")
        temp_command = temp_command.gsub("replace2", " word=\"" + item.w2.strip + "\" & ")
        corpus_counts = cqpcommand(temp_command)
        puts temp_command
	puts "^" * 3 + corpus_counts.to_s
	w2_fixed_count += corpus_counts

        corpus_counts = 0

        item.total_fixed_count = total_count
        item.w1_fixed_count = w1_fixed_count
        item.w2_fixed_count = w2_fixed_count
        item.save
        puts item.total_fixed_count
        puts item.w1
	puts item.w2
	puts item.w1_fixed_count
        puts item.w2_fixed_count
        puts "-" * 50


end



