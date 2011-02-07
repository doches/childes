# Scans a diretory for .cha files, converting any it finds into dialog XML
#
# Usage: ruby xmlize.rb <path/to/CHILDES/root>

require 'progressbar'

def scan(dir)
  if not dir.split('/').pop =~ /^\./ and File.directory?(dir)
    Dir.foreach(dir) do |file|
      path = File.join(dir,file)
      
      if File.directory?(path)
#        puts "SCANNING #{path}"
        scan(path)
      elsif path =~ /cha$/
        output = path.gsub(/\.cha$/,".xml")
        @files.push [path,output]
      end
    end
  end
end

@cha2xml = "ruby tools/cha2xml.rb --braces --clean --minipar --tag"
@files = []

path = ARGV.shift
Dir.foreach(path) { |dir| scan(File.join(path,dir)) if not dir =~ /^\./ }

STDERR.puts "Converting #{@files.size} .cha files to XML"
progress = ProgressBar.new("Converting",@files.size)
@files.each do |pair|
	path,output = *pair
	`cat #{path} | #{@cha2xml} > #{output} 2> /dev/null`
	progress.inc
end
progress.finish
