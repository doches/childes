# Takes a path to a directory containing XML (as ouput by **cha2xml**),
# finds all of the utterances therein, and writes a target corpus of
# all of them to standard out. Basically a wrapper around **xml2corpus**,
# and probably the sort of thing you're only interested in if you're also
# using [doches/corncob][].
#
# Usage: ruby tools/corpusize.rb path/to/xml/root
#
# @link doches/corncob http://github.com/doches/corncob

require 'tools/util'
require 'progressbar'

files = scan(ARGV.shift,/\.xml/)

progress = ProgressBar.new("Corpusizing",files.size)
files.each do |file|
  `ruby tools/xml2corpus.rb #{file}`.strip.split("\n").each { |line| puts line.strip }
  progress.inc
end
progress.finish