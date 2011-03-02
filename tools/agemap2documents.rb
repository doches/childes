# Reads an agemap from standard input and creates a set of nlda-friendly 
# corpora in <output>, binned into variable month periods
#
# Usage: cat [agemap] | ruby tools/agemap2nldacorpora.rb path/to/output

require 'progressbar'

output = ARGV.shift

bin_size = 1
bins = {}
STDIN.each_line do |line|
	age, key, path = *line.strip.split("\t")
	
	bins[(age.to_i / bin_size)*bin_size] ||= []
	bins[(age.to_i / bin_size)*bin_size].push [key,path]
end

# Parse each age/bin corpus
progress = ProgressBar.new("Corpusizing",bins.size)
bins.each_pair do |age,list|
  `mkdir -p #{File.join(output,age.to_s)}`
  list.each_with_index do |pair,index|
    path = File.join(output,age.to_s,"#{index}.target_corpus")
    `ruby tools/xml2document.rb #{pair[1]} #{pair[0]} > #{path}`
  end
  progress.inc
end
progress.finish
