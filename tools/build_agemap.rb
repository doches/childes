# Takes a directory containing CHILDES XML and prints a 
# mapping (tab-delimited) of child age to filename.
#
# Usage: ruby tools/build_agemap.rb path/to/childes

require 'tools/util'
require 'nokogiri'

files = []
scan(ARGV.shift,/xml$/).each do |file|
	doc = Nokogiri::XML(File.open(file))
	child = doc.xpath("//ID").reject { |node| not node.text.downcase.include?("child") }.map { |x| x.text }
	
	if not child.empty?
		if child[0].split("|")[3] =~ /(\d+)\;(\d+)?\.?(\d+)?/
			age = $1.to_i * 12 + $2.to_i
			key = child[0].split("|")[2]
			files.push [age,key,file]
		end
	else
		STDERR.puts "## #{file}"
		STDERR.puts doc.xpath("//ID").map { |x| x.text }.join("\n")
	end
end

files.sort { |a,b| a[0] <=> b[0] }.each { |pair| puts pair.join("\t") }

