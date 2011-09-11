
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
	has_many :disco_data_metrics

end

class DiscoDataMetric < ActiveRecord::Base
	set_table_name "disco_data_metrics"
	belongs_to :disco_data
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
                i_command = "Q1 = " + i_command + " ; size Q1; "
		command = open("./cqp-rip/temp_command2", "w")
                command.puts(i_command)
                command.close
                syscommand = "/opt/software/bin/cqp -e -D UKWAC1 -f /home/sak68/lex-project/scripts/cqp-rip/temp_command2 -p > /home/sak68/lex-project/scripts/test2"
                system(syscommand)
                temp = File.open("./test2", "r")
		count = 0
		for line in temp
			count = line.strip.to_i
		end
                return count
end



data = DiscoDataMetric.find(:all, :conditions => "x_11 is null and disco_data_id in (select id from disco_data where syntactic = 'EN_V_OBJ')")


for item in data
	next if item.disco_data.syntactic != "EN_V_OBJ"
	w1 = item.disco_data.w1
	w2 = item.disco_data.w2

	temp_command1 = "[(lemma='replace1')&(pos='V.*')][]{0,2}[(lemma='replace2')&(pos='NN.*')]"
	temp_command1 = temp_command1.gsub("replace1", w1.strip )
        temp_command1 = temp_command1.gsub("replace2", w2.strip )
	x11 = 0
	x11 = cqpcommand(temp_command1)	


	temp_command2 = "[(lemma!='replace1')&(pos='V.*')][]{0,2}[(lemma='replace2')&(pos='NN.*')]"
	temp_command2 = temp_command2.gsub("replace1", w1.strip)
        temp_command2 = temp_command2.gsub("replace2", w2.strip )
	x12 = 0
	x12 = cqpcommand(temp_command2)

	temp_command3 = "[(lemma='replace1')&(pos='V.*')][]{0,2}[(lemma!='replace2')&(pos='NN.*')]"
        temp_command3 = temp_command3.gsub("replace1", w1.strip )
        temp_command3 = temp_command3.gsub("replace2", w2.strip )
	x21 = 0
	x21 = cqpcommand(temp_command3)

	temp_command4 = "[(lemma!='replace1')&(pos='V.*')][]{0,2}[(lemma!='replace2')&(pos='NN.*')]"
        temp_command4 = temp_command4.gsub("replace1", w1.strip )
        temp_command4 = temp_command4.gsub("replace2", w2.strip )
	x22 = 0 
	x22 = cqpcommand(temp_command4)

	item.x_11 = x11
	item.x_12 = x12
	item.x_21 = x21
	item.x_22 = x22
	item.save

       	puts item.x_11
        puts item.x_12
	puts item.x_21
	puts item.x_22
        puts "----"
	#puts "-" * 50v


end



