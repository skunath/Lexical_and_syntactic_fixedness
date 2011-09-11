
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
		puts line	
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

data = DiscoData.find(:all, :conditions => ["syntactic = 'EN_ADJ_NN' and averag_complexity is null"], :group => "w1, w2")


for aset in data
	basecount = 0
	for distance in (0..2).to_a
		corpus_counts = 0
		adj_wild = 0
		noun_wild = 0
		# first pass for the semantic frame
		temp_command = "show -cpos;\n"
		temp_command += "show +pos +lemma;\n"
		temp_command += "set Context s;\n"
		#temp_command += "[word=\"" + aset.adj + "\" & pos=\"JJ\"] [word=\"" + aset.noun + "\" & pos=\"NN.*\"];"
		#temp_command += "[lemma=\"" + aset.w1 + "\" & pos=\"V.*\"] []{" + distance.to_s + "," + distance.to_s + "} [lemma=\"" + aset.w2 + "\"];"
		#temp_command += "[lemma=\"" + aset.w1 + "\"] []{" + distance.to_s + "," + distance.to_s + "} [lemma=\"" + aset.w2 + "\" & pos=\"V.*\"];"
		temp_command += "[word=\"" + aset.w1 + "\" & pos=\"JJ\"] []{" + distance.to_s + "," + distance.to_s + "} [word=\"" + aset.w2 + "\" & pos=\"NN.*\"];"
		
		puts temp_command	
		corpus_counts = cqpcommand(temp_command)					
		process_occurrences(aset.id, distance)	

		#temp_command = "[pos=\"JJ\"] " + "[word=\"" + aset.noun + "\" & pos=\"NN.*\"];"
                #puts temp_command
                #adj_wild = cqpcommand(temp_command)

                #temp_command = "[word=\"" + aset.adj + "\" & pos=\"JJ\"] " + "[pos=\"NN\"];"
                #noun_wild = cqpcommand(temp_command)

                #aset.adj_wild = adj_wild
                #aset.noun_wild = noun_wild
		#aset.corpus_count = corpus_counts
		#aset.save	
	puts "*" * 50
	end

end



