# Utility functions for CHILDES hacks.

# Scan a directory, returning a list of paths (relative to `dir`'s root) to all
# XML files found therein.
def scan(dir,match=/\.cha$/)
  files = []
  if not dir.split('/').pop =~ /^\./ and File.directory?(dir)
    Dir.foreach(dir) do |file|
      path = File.join(dir,file)
      
      if File.directory?(path)
#        puts "SCANNING #{path}"
        scan(path,match).each { |pair| files.push pair }
      elsif file =~ match
        files.push path
      end
    end
  end

  return files
end

# Poor man's option handling. Looks for boolean switches and, if found, sets the corresponding option in @options (a pre-set hashmap!) 
# and removes it from the argument list. Also checks for GNU-style shorthands ('-f' for '--foo') using the first character of an
# option's name. KEEP THEM UNIQUE!
def check_option(key)
  if ARGV.include?("--#{key}") or ARGV.include?("-#{key[0].chr}")
    ARGV.reject! { |x| x == "--#{key}" or x == "-#{key[0].chr}" }
    @options[key] = true
  else
  	@options[key] = false
  end
end