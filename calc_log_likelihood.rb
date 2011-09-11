
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
	:adapter => "mysql2",
	:host => "localhost",
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


def l_func(k, n , x)
	puts "k -> " + k.to_s + " n -> " + n.to_s + " x -> " + x.to_s

	calc = 0
	#calc =   (x**k) * ((1 - x)**(n-k))
	begin
	calc =  (k * Math.log(x)) + ( (n-k) * Math.log(1 - x))
	rescue
	end
	puts calc
	return calc	
end



data = DiscoDataMetric.find(:all)

p_count = 3717249

for item in data
	calc = 0
	p = 0
	p1 = 0
	p2 = 0

	c1 = item.x_21.to_f
	c2 = item.x_12.to_f
	c12 = item.x_11.to_f

	p = c2 / p_count
	p1 = c12 / c1
	p2 = (c2 - c12)/ (p_count - c1)
	puts l_func(c12, c1, p)

	calc = l_func(c12,c1, p) + l_func(c2 - c12, p_count - c1, p) - l_func(c12, c1, p1) - l_func(c2 - c12, p_count - c1, p2) 
	
        puts calc
	item.log_likelihood = calc
	item.save
	puts "----"
	#puts "-" * 50v


end



