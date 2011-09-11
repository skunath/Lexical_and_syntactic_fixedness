
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

class DiscoSynTemplate < ActiveRecord::Base
	set_table_name "disco_syn_templates"
end

class DiscoSynFrameCount < ActiveRecord::Base
	set_table_name "disco_syn_frame_counts"
end



data = DiscoData.find(:all, :conditions => ["syntactic = 'EN_V_OBJ' and set_id = 3 and averag_complexity is null and w1_fixed_count is not null"])


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
	puts aset.w1 + " -- " +  aset.w2
	for pattern in DiscoSynTemplate.find(:all, :conditions => ["syntactic_frame = ?", aset.syntactic.strip])
		temp_command = pattern.template
		temp_command = temp_command.gsub("replace1","& lemma=\"" + aset.w1.strip + "\"")
		temp_command = temp_command.gsub("replace2","& lemma=\"" + aset.w2.strip + "\"")
		corpus_counts = cqpcommand(temp_command)					
		temp = DiscoSynFrameCount.new
		puts "another frame..."
		temp.disco_syn_template_id = pattern.id
		temp.disco_data_id = aset.id
		temp.corpus_count = corpus_counts
		temp.save
	end
end
