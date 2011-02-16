# Reads a list of noun/counts (as output by extract_nouns) from STDIN,
# filtering the list to include only nouns appearing in WordNet (as nouns).
# Requires [doches/rwordnet][].
# 
# Usage: [cat noun.txt] | ruby tools/filter_nouns.rb
#
# @link doches/rwordnet http://github.com/doches/rwordnet

require 'wordnet'

index = WordNet::NounIndex.instance
STDIN.each_line do |line|
	noun = line.strip.split(/\s+/).shift
	
	lemma = index.find(noun)
	if not lemma.nil?
		print line
#		puts lemma.synsets[0].expanded_hypernym.map { |synset| synset.words }.join(" / ")
	end
end
