# Filters a target corpus (from standard input) to include only lines involving target
# words from a list, printing the result to standard out. Used to clean up the output 
# of **xml2corpus** according to the output of **filter_nouns**.
#
# Usage: [cat file.target_corpus] | ruby tools/filter_corpus.rb path/to/nouns.filtered

nouns = IO.readlines(ARGV.shift).map { |line| line.strip.split(/\s+/).shift }

STDIN.each_line do |line|
  print line if nouns.include?(line.strip.split(/\s+/).shift)
end