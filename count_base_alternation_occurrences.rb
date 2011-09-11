
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

class DiscoFrame < ActiveRecord::Base
	set_table_name "disco_frames"
	belongs_to :disco_data
end
class DiscoOccurrence < ActiveRecord::Base
	set_table_name "disco_occurrences"
	belongs_to :disco_data
	validates_uniqueness_of :sentence, :scope => :disco_data_id

end

class DiscoSynTemplate < ActiveRecord::Base
	set_table_name "disco_syn_templates"
end



data = DiscoData.find(:all, :conditions => "syntactic = 'EN_ADJ_NN'")

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


def process_occurrences(id, distance)
	temp_file = File.open("./test","r")
	for line in temp_file
		begin
		t_o = DiscoOccurrence.new()
		t_o.distance = distance
		t_o.disco_data_id = id
		t_o.sentence = line.strip
		t_o.save
		rescue
			puts "error..."
		end

	end

end

for aset in data
	syns = DiscoSynTemplate.find(:all, :conditions => ["syntactic_frame = ?", aset.syntactic])
	w1_totals = 0
	w2_totals = 0

	for syn in syns
		for alter in aset.disco_frames		
			if alter.replacing_word == 2
				replace1 = "& lemma=\"" + aset.w1.strip + "\""
				replace2 = "& word=\"" + alter.w.strip + "\""
			else
				replace1 = "& word=\"" + alter.w.strip + "\""
				replace2 = "& lemma=\"" + aset.w2.strip + "\""
			end
			temp_command = syn.template
			temp_command = temp_command.gsub("replace1", replace1)
			temp_command = temp_command.gsub("replace2", replace2)
			puts temp_command
			corpus_counts = cqpcommand(temp_command)					
			if alter.replacing_word == 2
				w1_totals += corpus_counts
			else
				w2_totals += corpus_counts
			end
			puts corpus_counts
		end
	end

	aset.w1_fixed_count = w1_totals
	aset.w2_fixed_count = w2_totals
	aset.save

end
