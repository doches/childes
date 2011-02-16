# Replicates the directory structure of *input* in *output*, copying
# only xml files over into the new structure. Use this after **xmlize**, 
# to build a version of CHILDES containing only XML. You don't have to 
# do this (other tools will silently ignore `.cha` files, preferring XML), 
# but it satisfies my housekeeping urges.
#
# Usage: ruby tools/centralize_xml.rb path/to/CHILDES/input path/to/xml/output

require 'fileutils'

input = ARGV.shift
output = ARGV.shift

def clone(from,to)
	if File.directory?(from)
		Dir.foreach(from) do |file|
			clone(File.join(from,file),File.join(to,from.split('/').pop)) if not file =~ /^\./
		end
	elsif from =~ /xml$/
		FileUtils.mkdir_p(to) if not File.exists?(to)
		FileUtils.cp(from,to)
		STDERR.puts "#{from.split('/').pop}\t -> #{to}"
	end
end

`mkdir -p #{output}` if not File.exists?(output)

clone(input,output)
