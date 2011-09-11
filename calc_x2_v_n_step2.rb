
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



data = DiscoDataMetric.find(:all, :conditions => " disco_data_id in (select id from disco_data where syntactic = 'EN_V_OBJ')")


for item in data
	calc_upper = 0
	calc_upper = (item.x_11 * item.x_22) - (item.x_12 * item.x_21)
	calc_upper = calc_upper ** 2
	calc_upper = calc_upper * 3717249

	calc_lower = 0
	calc_lower = ( (item.x_11 + item.x_12) * (item.x_11 + item.x_21) * (item.x_12 + item.x_22) * (item.x_21 + item.x_22) )

	final = calc_upper / (calc_lower + 1)
	item.x_square = final
	item.save
        puts item.x_square
	puts "----"
	#puts "-" * 50v


end



