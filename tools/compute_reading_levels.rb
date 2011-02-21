# Compute reading levels for each document in a directory, and produce
# a data file ready for plotting with GnuPlot.
#
# Usage: ruby tools/compute_reading_levels.rb path/to/dir > file.dat

require 'tools/util'
require 'tools/natcmp'
require 'progressbar'

options = %w{coleman fkre words syllables characters}.map { |k| "--#{k}" }.join(" ")

header = nil

files = scan(ARGV.shift,/^[^\.]/).map { |path| [path,path.split("/").pop] }.sort { |a,b| String.natcmp(a[1],b[1]) }.map { |pair| pair[0] }
progress = ProgressBar.new("Computing",files.size)
files.each do |file|
  key = file.split("/").pop.split(".")
  key.pop
  key = key.join(".")
  output = `ruby tools/reading_level.rb #{file} #{options}`.split("\n")
  if header.nil?
    header = output[0]
    puts header
  end
  output = output[1]
  puts [output.strip.split("\t"),key].flatten.join("\t")
  progress.inc
end
progress.finish