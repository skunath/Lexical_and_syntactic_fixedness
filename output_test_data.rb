
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




#data = DiscoData.find_by_sql("
#select d.*, n.x_square, n.log_likelihood, o.lex_fix, o.overall_fix, o.complexity_0, complexity_1, complexity_2, complexity_3, complexity_4,length_0, length_1, length_2, length_3, length_4 from 
#disco_data d 
#left outer join disco_data_computations o on o.disco_data_id = d.id
#left outer join disco_data_metrics n on n.disco_data_id = d.id
#where (d.set_id = 3) and d.syntactic like \"%ADJ_NN%\" 
#group by w1, w2
#")


data = DiscoData.find_by_sql("
select d.*, n.x_square, n.log_likelihood, o.lex_fix, o.overall_fix, o.complexity_0, complexity_1, complexity_2, complexity_3, complexity_4,length_0, length_1, length_2, length_3, length_4 from 
disco_data d 
left outer join disco_data_computations o on o.disco_data_id = d.id
left outer join disco_data_metrics n on n.disco_data_id = d.id
where (d.set_id = 3) and d.syntactic like '%V_OBJ%' 
group by w1, w2
")

test_data = File.open("test-obj-n-list-3.txt")
test_scores = {}

for line in test_data
	break if line.strip == ""
	line_split = line.split()
	puts line_split.to_s
	test_scores[line_split[0]] = line_split[2].strip
end

test_out = File.open("out-v-n-list.txt", "w")

counter = 1
for item in data
	line = "EN_V_OBJ\t"
	line += item.w1.strip + " " + item.w2.strip + "\t"
	line += test_scores[counter.to_s] + "\n"

	test_out.write(line)
	counter += 1
end

test_out.close

