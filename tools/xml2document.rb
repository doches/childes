# Takes an XML file, extracts all of the utterances, and prints them to 
# standard output for later processing.
#
# Takes an optional key to ignore (e.g. CHI)
#
# Usage: ruby tools/xml2document.rb path/to/childes.xml <ignore_key>

require 'nokogiri'

xml = Nokogiri::XML(File.open(ARGV.shift))
key = ARGV.empty? ? nil : ARGV.shift

utterances = xml.xpath("//utterance").each do |utterance|
  sentence = (utterance/"text").text.split(/\s+/)
	speaker = (utterance/"speaker").text
	
  puts sentence.join(" ") if speaker != key
end