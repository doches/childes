# Compute reading levels (e.g. [Coleman-Liau Index][], [Automated Readability Index][], [Flesh-Kincaid][] Readability Test) for a given target_corpus
#
# Input:
# One sentence per line.
# 
# Usage: ruby tools/reading_level.rb path/to/file.target_corpus <options>
#
# 
#
# Output:
# Prints a tab-delimited list of metric names as a comment (e.g. "# coleman  ari words"), followed
# by a tab-delimited list of computed metrics (e.g. "4.3  4.1 6.0 132.8")
#
# Options:
#    + **--ari** [Automated Readability Index][]
#    + **--coleman** [Coleman-Liau Index][]
#    + **--fkre** [Flesh-Kincaid][] Readability Test
#    + **--words** Average number of words per sentence
#    + **--syllables** Average number of syllables per sentence
#    + **--characters** Average number of characters per sentence
#
# @link "Coleman-Liau Index" http://en.wikipedia.org/wiki/Coleman-Liau_Index
# @link "Automated Readability Index" http://en.wikipedia.org/wiki/Automated_Readability_Index
# @link "Flesh-Kincaid" http://en.wikipedia.org/wiki/Flesch-Kincaid_Readability_Test

require 'tex/hyphen'
require 'tools/util'

%w{ari coleman fkre words syllables characters}.each { |method| check_option method }

class ReadingMetric  
  def initialize(sentences,words,syllables,characters)
    @sentences = sentences.to_f
    @words = words.to_f
    @syllables = syllables.to_f
    @characters = characters.to_f
  end
  
  def ari
    4.71 * (@characters / @words) + 0.5 * (@words / @sentences) - 21.43
  end
  
  def coleman
    0.0588 *(@characters / (@words/100)) - 0.296*(@sentences / (@words/100)) - 15.8
  end
  
  def fkre
    206.835 - 1.015 * (@words / @sentences) - 84.6 * (@syllables / @words)
  end
  
  def words
    @words / @sentences
  end
  
  def syllables
    @syllables / @sentences
  end
  
  def characters
    @characters / @sentences
  end
end

corpus = ARGV.shift
hyp = TeX::Hyphen.new

sentences = 0
words = 0
characters = 0
syllables = 0
IO.foreach(corpus) do |line|
  line.strip!
  
  sentences += 1
  words += line.split(/\s+/).count
  characters += line.size
  syllables += line.split(/[\\s\-]+/).map { |word| hyp.visualize(word).split("-") }.map { |x| x.count }.inject(0) { |s,x| s += x }
end

metric = ReadingMetric.new(sentences,words,syllables,characters)

options = @options.map { |k,v| [k,v] }.reject { |pair| not pair[1] }.map { |x| x[0] }
puts "# #{options.join("\t")}"
puts options.map { |x| metric.send(x.to_sym) }.join("\t")