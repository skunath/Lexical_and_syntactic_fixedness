
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




def cqpcommand(i_command)
		begin
			File.delete("/home/sak68/lex-project/scripts/cqp-rip/temp_command" + $execer)
			File.delete("/home/sak68/lex-project/scripts/test" + $execer)
		rescue
		end
		command = open("./cqp-rip/temp_command" + $execer, "w")
		command.puts("Go#{$execer} = #{i_command} size Go#{$execer};" )
		command.close
		syscommand = "/opt/software/bin/cqp -e -D UKWAC1 -f /home/sak68/lex-project/scripts/cqp-rip/temp_command#{$execer} -p"
		temp_count = `#{syscommand}`
		puts temp_count
		#return_count = `wc -l ./test`
		#return return_count.strip().to_i
		return temp_count.to_i
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

data = DiscoFrame.find(:first, :conditions => "disco_data_id in (select id from disco_data where syntactic = 'EN_V_OBJ' and (set_id = 2 or set_id = 1)) ", :order => "rand()")
templates = DiscoSynTemplate.find(:all, :conditions => "syntactic_frame = 'EN_V_OBJ'")
$execer = "3"

while !data.nil?
	aset = data
        total_count = 0
        w1_fixed_count = 0
        w2_fixed_count = 0

	if aset.replacing_word == 2
		w1 = aset.disco_data.w1
		w2 = aset.w
	else
		w1 = aset.w
		w2 = aset.disco_data.w2
	end

	for template in templates 
		temp_command = template.template
		temp_command = temp_command.gsub("replace1", " & word=\"" + w1.strip + "\"")
		temp_command = temp_command.gsub("replace2", " & word=\"" + w2.strip + "\"")
		puts temp_command
		corpus_counts = cqpcommand(temp_command)
		total_count += corpus_counts
		puts "^" * 3 + corpus_counts.to_s
		corpus_counts = 0

		temp_command = template.template
		temp_command = temp_command.gsub("replace1", " &  word=\"" + w1.strip + "\"")
		temp_command = temp_command.gsub("replace2", "")
		puts temp_command
		corpus_counts = cqpcommand(temp_command)
		w1_fixed_count += corpus_counts
		puts "^" * 3 + corpus_counts.to_s
		corpus_counts = 0

		temp_command = template.template
		temp_command = temp_command.gsub("replace1", "")
		temp_command = temp_command.gsub("replace2", " & word=\"" + w2.strip + "\"")
		corpus_counts = cqpcommand(temp_command)
		puts temp_command
		puts "^" * 3 + corpus_counts.to_s
		w2_fixed_count += corpus_counts

	end

        corpus_counts = 0

        aset.total_fixed_count = total_count
        aset.w1_fixed_count = w1_fixed_count
        aset.w2_fixed_count = w2_fixed_count
        aset.save
        puts aset.total_fixed_count
        puts aset.w1_fixed_count
        puts aset.w2_fixed_count

data = DiscoFrame.find(:first, :conditions => "disco_data_id in (select id from disco_data where syntactic = 'EN_V_OBJ' and (set_id = 2 or set_id = 1)) ", :order => "rand()")

end
