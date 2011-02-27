# Reads an agemap from standard input and creates a set of nlda-friendly 
# corpora in <output>, binned into six-month periods
#
# Usage: cat [agemap] | ruby tools/agemap2nldacorpora.rb path/to/output

require 'progressbar'

output = ARGV.shift

bins = {}
STDIN.each_line do |line|
	age, key, path = *line.strip.split("\t")
	
	bins[(age.to_i / 6)*6] ||= []
	bins[(age.to_i / 6)*6].push [key,path]
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
