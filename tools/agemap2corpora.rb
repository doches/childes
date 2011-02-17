# Reads an agemap from standard input and creates a set of corpora in <output>,
# one per each six-month period
#
# Usage: cat [agemap] | ruby tools/agemap2corpora.rb path/to/output

require 'progressbar'

output = ARGV.shift
partdir = "partials"
`mkdir -p #{File.join(output,partdir)}` if not File.exists?(File.join(output,partdir))

bins = {}
STDIN.each_line do |line|
	age, key, path = *line.strip.split("\t")
	
	bins[(age.to_i / 6)*6] ||= []
	bins[(age.to_i / 6)*6].push [key,path]
end

# Parse each age/bin corpus
progress = ProgressBar.new("Corpusizing",bins.size)
bins.each_pair do |age,list|
	path = File.join(output,partdir,"#{age}.target_corpus")
	if not File.exists?(path)
		text = list.map { |pair| `ruby tools/xml2corpus.rb #{pair[1]} #{pair[0]}` }.join("")
	
		fout = File.open(path,"w")
		fout.puts text
		fout.close
	end
	progress.inc
end
progress.finish

epochs = bins.keys.sort
progress = ProgressBar.new("Concatenating",epochs.size)
(0..epochs.size-1).each do |index|
	p epochs[index]
	target = File.join(output,"#{epochs[index]}.target_corpus")
	epochs[0..index].each do |age| 
		partial = File.join(output,partdir,"#{age}.target_corpus")
		`cat #{partial} >> #{target}`
	end
	progress.inc
end
progress.finish
