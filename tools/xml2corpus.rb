# Takes an XML file, extracts all of the utterances, and prints a TargetCorpus
# (see doches/corncob) using nouns from the POStag list as target words.
#
# Takes an optional key to ignore (e.g. CHI)
#
# Usage: ruby tools/xml2corpus.rb path/to/childes.xml <ignore_key>

require 'nokogiri'

xml = Nokogiri::XML(File.open(ARGV.shift))
key = ARGV.empty? ? nil : ARGV.shift

utterances = xml.xpath("//utterance").each do |utterance|
	speaker = (utterance/"speaker").text
  tags = (utterance/"tags").text.split(/\s+/)
  sentence = (utterance/"text").text.split(/\s+/)
  
  tags.each_with_index do |pair,i|
    word,tag = *pair.split("/")
    
    if tag =~ /^N/ and word != "xxx"
      if i == 0
        puts [word,sentence[1..sentence.size]].flatten.join(" ")
      elsif i == sentence.size-1
        puts [word,sentence[0..sentence.size-2]].flatten.join(" ")
      else
        puts [word,sentence[0..i-1],sentence[i+1..sentence.size]].flatten.join(" ")
      end
    end
  end if sentence.size > 1 && speaker != key
end

#tags = xml.xpath("//tags").map { |x| x.text.split(/\s+/).map { |y| y.split("/") } }
#tags.map { |list| list.reject { |pair| not pair[1] =~ /^N/ } }.reject { |list| list.empty? }.flatten(1)
