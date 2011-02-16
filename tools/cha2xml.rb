# Reads a [CHILDES][] .cha file from STDIN and outputs XML file containing cleaned
# dialog to STDOUT
#
# Usage: [cat thing.cha] | ruby cha2xml.rb <options>
#
# Options: 
# **xmlize** calls cha2xml with *all* of these options on by default
# 
#    + **--braces** Strip out experimenter annotations ("foo [this is a note] bar") from utterances.
#    + **--clean** Remove words containing nonsensical (i.e. non-word) characters.
#    + **--minipar** Run utterances through MINIPAR, including the result in the `<parse>` tag. Looks for `./vendor/pdemo/pdemo`, with data files in `./vendor/data`.
#    + **--tag** Run utterances through a [pure Ruby implementation of the Brill tagger](http://rubygems.org/gems/rbtagger), including the result in the `<tags>` tag.
#
# @link CHILDES http://childes.psy.cmu.edu/

require 'nokogiri'
require 'progressbar'
require 'tools/util'

@options = {}
check_option "braces"
check_option "clean"
check_option "minipar"
check_option "tag"

tagger = nil
if @options['tag']
	require 'rbtagger'
	tagger = Brill::Tagger.new
end

meta = {}
dialogs = []
speaker = false
STDIN.each_line do |line|
	if line =~ /^@([^:]+):\s*(.*)$/
		key = $1
		value = $2
		value = value.split(",").map { |x| x.strip } if value.include?(",")
		if meta[key]
			if not meta[key].is_a?(Array)
				meta[key] = [meta[key]]
			end
			meta[key].push value
		else
			meta[key] = value
		end
  elsif line =~ /^\*(\w+):\s+([^%\n\025]+)/
    speaker = $1
    content = $2
    dialogs.push({:speaker => speaker, :content => content})
  elsif speaker and line =~ /^\s+([^%]+)/
    extra_content = $1
    dialogs[dialogs.size-1][:content] += " #{extra_content}"
  else
    speaker = false
  end
end

# Strip annotations, clean weird characters, and POS-tag
dialogs.each do |pair|
  pair[:content] = pair[:content].gsub(/\[[^\]]+\]\s?/,"") if @options["braces"]
  pair[:content] = pair[:content].split(/\s+/).reject { |word| not word =~ /^\w+$/ }.join(" ") if @options["clean"]
  pair[:content] = pair[:content].strip
  
  if @options['tag']
  	tags = tagger.tag( pair[:content] )
  	pair[:tags] = tags.reject { |x| x[0].size <= 0 }.map { |tuple| tuple.join("/") }.join(" ")
  end
end

# Remove empty utterances
dialogs.reject! { |pair| pair[:content].length <= 0 }

if @options['minipar']
	# Parse all at once, rather than loading the parser every time
	sentences = dialogs.map { |dialog| dialog[:content] }.join("\n")
	parse = `echo "#{sentences}" | ./vendor/pdemo/pdemo -i -l -t -p ./vendor/data 2> /dev/null`
	
	sentence = []
	dialog_index = 0
	parse.split("\n").each do |line|
		line.strip!
		if line.size <= 0
			dialogs[dialog_index][:minipar] = sentence.map { |x| x.split("\t") }
			sentence = []
			dialog_index += 1
		else
			sentence.push line
		end
	end
end
  
# Generate XML
builder = Nokogiri::XML::Builder.new do |xml|
  xml.root {
  	meta.each_pair { |key,value|
  		begin
  		if value.is_a?(Array)
  			value.each { |x| eval("xml.#{key} x") }
  		else
	  		eval("xml.#{key} value")
	  	end
	  	rescue
	  		STDERR.puts "Unable to encode meta key-value pair \"#{key}\",\"#{value}\""
	  	end
  	}
    xml.dialog {
      dialogs.each { |utterance|
        xml.utterance {
          xml.speaker utterance[:speaker]
          xml.text_ utterance[:content]
          xml.tags utterance[:tags] if @options['tag']
          if @options['minipar'] and utterance[:minipar]	
          	xml.parse {
          		utterance[:minipar].each { |dep|
          			xml.dependency dep.join("\t")
          		}
          	}
          end
        }
      }
    }
  }
end

puts builder.to_xml
