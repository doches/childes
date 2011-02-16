# Adds tool sections to README.mdown.skel, and outputs a final
# README.mdown
#
# Usage: ruby tools/make_readme.rb
#
# Format:
# See this header in `tools/make_readme.rb`
#
# Special keys:
# **make_readme** understands a few special flags:
# 
#    + **@nodoc** -- don't include documentation for this tool in the README.
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
				if line =~ /^@link ([^ ]+) ([^ ]+)$/
					# A URL link
					links[$1.strip] = $2.strip
				elsif line =~ /^([^ :]+): ?(.+)?/
					# A subheading, with optional code afterwards (e.g. "Options:" or "Usage: ...code...")
					header.push "\n#### #{$1.capitalize}\n\n"
					header.push "    #{$2.rstrip}\n\n" if $2
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

fout = File.open("README.mdown","w")
fout.puts skeleton.map { |line| line.gsub(/==[^=]+==/,skeleton_keys) }.join("")
fout.close
