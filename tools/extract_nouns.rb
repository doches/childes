# Looks recursively in <dir> for xml, scanning each file found
# for nouns in the POS tag list and outputting a list of all nouns
# found (plus counts)
#
# Usage: ruby tools/extract_nouns.rb path/to/xml/root

require 'nokogiri'
require 'progressbar'

input = ARGV.shift

def scan(dir)
	files = []
	if File.directory?(dir)
		Dir.foreach(dir) do |file|
			files.push scan(File.join(dir,file)) if not file =~ /^\./
		end
	elsif dir =~ /xml$/
		files.push dir
	end
	
	files.flatten
end

def find_nouns(file)
	xml = Nokogiri::XML(File.open(file))
	
	tags = xml.xpath("//tags").map { |x| x.text.split(/\s+/).map { |y| y.split("/") } }
	tags.map { |list| list.reject { |pair| not pair[1] =~ /^N/ } }.reject { |list| list.empty? }.flatten(1)
end

nouns = {}
files = scan(input)
progress = ProgressBar.new("Scanning",files.size)
files.each do |file|
	find_nouns(file).each do |pair|
		nouns[pair[0]] ||= 0
		nouns[pair[0]] += 1
	end
	progress.inc
end
progress.finish

nouns.map { |k,v| [k,v] }.sort { |b,a| a[1] <=> b[1] }.each do |pair|
	puts pair.join("\t")
end
