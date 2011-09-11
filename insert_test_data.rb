require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
        :adapter => "mysql2",
        :host => "localhost",
        :username => "lex_mini_project",
        :password => "lex-project",
        :database => "lex_mini_project"
)

class DiscoData < ActiveRecord::Base
        set_table_name "disco_data"
end


open_file = File.open("./DISCo_EN_test-unlabeled.tsv", "r")

for line in open_file
                temp_line = line.strip().split()

                new_row = DiscoData.new()
                new_row.syntactic = temp_line[0]
                new_row.w1 = temp_line[1]
                new_row.w2 = temp_line[2]
                new_row.set_id = 3
                new_row.save

        end




