# Reads a list of noun/count pairs from STDIN (like the output of
# extract_nouns or filter_nouns) and prints a yaml clustering based
# on their first-order WordNet synsets.
#
# Usage: [cat noun.list] | ruby tools/cluster_wordnet_nouns.rb

require 'wordnet'

index = WordNet::NounIndex.instance

clusters = {}
STDIN.each_line do |line|
	noun = line.strip.split(/\s+/).shift
	synset = index.find(noun).synsets[0].hypernym
	
	begin
		key = synset.words.join(", ")
		clusters[key] ||= []
		clusters[key].push noun
	rescue NoMethodError
		STDERR.puts noun
		STDERR.puts index.find(noun).synsets[0]
	end
end

puts clusters.to_yaml
