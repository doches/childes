# Scans a diretory for .cha files, converting any it finds into dialog XML
#
# Usage: ruby xmlize.rb <path/to/CHILDES/root>

require 'progressbar'
require 'tools/util'

@cha2xml = "ruby tools/cha2xml.rb --braces --clean --minipar --tag"
@files = scan(ARGV.shift,/\.cha$/).map { |file| [file,file.gsub(/\.cha$/,".xml")] }

STDERR.puts "Converting #{@files.size} .cha files to XML"
progress = ProgressBar.new("Converting",@files.size)
@files.each do |pair|
	path,output = *pair
	`cat #{path} | #{@cha2xml} > #{output} 2> /dev/null`
	progress.inc
end
progress.finish
