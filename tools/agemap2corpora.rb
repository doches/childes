# Reads an agemap from standard input and creates a set of corpora in <output>,
# one per each six-month period
#
# Usage: cat [agemap] | ruby tools/agemap2corpora.rb path/to/output

output = ARGV.shift
`mkdir -p #{output}` if not File.exists?(output)

bins = {}
STDIN.each_line do |line|
	age, key, path = *line.strip.split("\t")
	
	bins[(age.to_i / 6)*6] ||= []
	bins[(age.to_i / 6)*6].push [key,path]
end

bins.each_pair do |age,list|
	text = list.map { |pair| `ruby tools/xml2corpus.rb #{pair[1]} #{pair[0]}` }.join("")
	
	fout = File.open(File.join(output,"#{age}.target_corpus"),"w")
	fout.puts text
	fout.close
end
