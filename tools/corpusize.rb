# Takes a path to a directory containing XML (as ouput by **cha2xml**),
# finds all of the utterances therein, and writes a target corpus of
# all of them to standard out.
#
# Usage: ruby tools/corpusize.rb path/to/xml/root

require 'tools/util'
require 'progressbar'

files = scan(ARGV.shift,/\.xml/)

progress = ProgressBar.new("Corpusizing",files.size)
files.each do |file|
  `ruby tools/xml2corpus.rb #{file}`.strip.split("\n").each { |line| puts line.strip }
  progress.inc
end
progress.finish