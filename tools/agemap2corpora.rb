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

# Concatenate into chunks (e.g. 0-6, 0-12, 0-18, ...)
epochs = bins.map { |age,list| [age,list] }.sort { |a,b| a[0] <=> b[0] }
epochs.each_with_index do |epoch, index|
  progress = ProgressBar.new(epoch[0].to_s,index+1)
  (0..index).map { |subindex| epochs[subindex][0] }.each do |bin|
  	`cat #{File.join(output,partdir,"#{epochs[bin][0]}")} >> #{epoch[0]}.target_corpus`
  end
end
