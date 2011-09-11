
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
	has_many :disco_syn_templates
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

class DiscoSynTemplate < ActiveRecord::Base
	set_table_name "disco_syn_templates"
	belongs_to :disco_data
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



data = DiscoData.find(:all, :conditions => ["syntactic = 'EN_V_OBJ'"], :group => "w1, w2", :order => "set_id")
frames = DiscoSynTemplate.find(:all, :conditions => ["syntactic_frame = 'EN_V_OBJ'"])


for item in data
	total_count = 0
	w1_fixed_count = 0
	w2_fixed_count = 0

	for replacement in frames
	temp_command = replacement.template
	temp_command = temp_command.gsub("replace1", " & word=\"" + item.w1 + "\"")
	temp_command = temp_command.gsub("replace2", " & word=\"" + item.w2 + "\"")
	corpus_counts = cqpcommand(temp_command)
	total_count += corpus_counts
	corpus_counts = 0
	
	temp_command = replacement.template
        temp_command = temp_command.gsub("replace1", " & word=\"" + item.w1 + "\"")
        temp_command = temp_command.gsub("replace2", "")
        corpus_counts = cqpcommand(temp_command)
        w1_fixed_count += corpus_counts
	corpus_counts = 0	

	temp_command = replacement.template
        temp_command = temp_command.gsub("replace1", "")
        temp_command = temp_command.gsub("replace2", " & word=\"" + item.w2 + "\"")
        corpus_counts = cqpcommand(temp_command)
        w2_fixed_count += corpus_counts
	corpus_counts = 0
	end


	item.total_fixed_count = total_count
	item.w1_fixed_count = w1_fixed_count
	item.w2_fixed_count = w2_fixed_count
	item.save
	puts item.total_fixed_count
	puts item.w1_fixed_count
	puts item.w2_fixed_count
	puts "-" * 50
end



