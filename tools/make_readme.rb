# @nodoc
# Adds tool sections to README.mdown.skel, and outputs a final
# README.mdown
#
# Usage: ruby tools/make_readme.rb
#
# Format:
# See this header in `tools/make_readme.rb`
#
# Special_keys:
# **make_readme** understands a few special flags:
# 
#    + **@nodoc** -- don't include documentation from this point on in the README. 
#      If this is the first line, don't document this tool at all.
#    + **@link [key] [url]** -- add a url reference to the bottom of the README (e.g. `@link CHILDES http://childes.psy.cmu.edu/`).

skeleton = IO.readlines("README.mdown.skel")

tooldir = "tools"
tools = {}
links = {}
Dir.foreach(tooldir) do |file|
	if file =~ /rb$/
		header = []
		nodoc = false
		IO.foreach(File.join(tooldir,file)) do |line|
			if line[0].chr == "#"
				line = line[2..line.size]
				break if line =~ /^@nodoc/
				if line =~ /^@link \"?([^\"]+)\"? \"?([^ ]+)\"?$/
					# A URL link
					links[$1.strip] = $2.strip
				elsif line =~ /^([^ :]+): ?(.+)?/
					# A subheading, with optional code afterwards (e.g. "Options:" or "Usage: ...code...")
					info = $2
					header.push "\n#### #{$1.capitalize.gsub("_"," ")}\n\n"
					header.push "    #{info.rstrip}\n\n" if info
				else
					# Just a normal line
					header.push line
				end
			else
				break
			end
		end
		tools[file.split(".",2)[0].gsub("_","\\_")] = header.join("") if header.size > 0
	end
end

skeleton_keys = {
	"==TOOLS==" => tools.map { |tool,desc| "## #{tool}\n\n#{desc}" }.join("\n\n\n\n"),
	"==LINKS==" => links.map { |key,url| "  [#{key}]: #{url}" }.join("\n")
}

skeleton.each do |line|
  skeleton_keys.each { |k,v| line.gsub!(k,v) }
end

fout = File.open("README.mdown","w")
fout.puts skeleton
fout.close
