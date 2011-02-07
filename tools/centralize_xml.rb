# Replicates the directory structure of <input> in <output>, copying
# only xml files over into the new structure.
#
# Usage: ruby tools/centralize_xml.rb path/to/CHILDES/root path/to/xml/root

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

clone(input,output)
