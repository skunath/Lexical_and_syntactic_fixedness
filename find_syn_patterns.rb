
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

class DiscoSynFrame < ActiveRecord::Base
	set_table_name "disco_syn_frames"
	belongs_to :disco_data

	def self.new_syn(disco_data_id, distance, pos_track, lemma_track, word_track)
		temp = self.find(:first, :conditions => ["disco_data_id = ? and distance = ? and pos_track = ?", disco_data_id, distance, pos_track]) 
		if !temp.nil?
			temp.count += 1
			temp.save
		else
			temp = self.new()
			temp.disco_data_id = disco_data_id
			temp.pos_track = pos_track
			temp.distance = distance
			temp.count = 1
			temp.save	
		end
	end

end



data = DiscoOccurrence.find(:all)

$window = 1

for aset in data
	broke_sentence = aset.sentence.split
	word = []
	lemma = []
	pos = []

	target1 = 0
	target2 = 0

begin 
	
	target_watch = 0
	for item in broke_sentence
		target = 0
		if item.include?("<")
			target1 = target_watch
			item = item.gsub("<", "")
			target = 1
		end 
		if item.include?(">")
			target2 = target_watch
			item = item.gsub(">","")
			target = 1
		end
		new_split = item.split("/")
		
		if target == 1
			word << "*" + new_split[0] + "*"
			pos << "*" + new_split[1] + "*"
			lemma << "*" + new_split[2] + "*"


		else
			word << new_split[0]
			pos << new_split[1]
			lemma << new_split[2]
		end

		target_watch += 1
	end

	puts target1.to_s + " -- " + target2.to_s
	
	lower_bound = 0
	upper_bound = -1
	if target1 - $window > 0
		lower_bound = target1 - $window
	end

	if target2 + $window < broke_sentence.size
		upper_bound = target2 + $window
	end

	pos_track = pos[lower_bound..upper_bound].join(" ")
	word_track = word[lower_bound..upper_bound].join(" ")
	lemma_track = lemma[lower_bound..upper_bound].join(" ")

	
	DiscoSynFrame.new_syn(aset.disco_data_id, aset.distance, pos_track, lemma_track, word_track)

	puts pos_track
rescue 
	puts "Error on this one..."
	puts "dis: " + aset.distance.to_s + " -- " + aset.sentence
end
	
	puts "*" * 50	
end



