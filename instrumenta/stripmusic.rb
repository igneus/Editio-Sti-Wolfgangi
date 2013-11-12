# read inputfile/stdin, 
# write to outputfile/stdout/inputfile 
# without gregorio music (i.e. anything in brackets)

require 'optparse'
require 'stringio'

setup = {
  :output_file => nil,
  :overwrite => false,
  :input_files => []
}

optparse = OptionParser.new do|opts|
  opts.on "-o", "--output FILE", "Path of an output file" do |path|
    setup[:output_file] = File.open(path, 'w')
  end

  opts.on "-O", "--overwrite", "Output in the input file" do
    setup[:overwrite] = true
  end
end
optparse.parse!

# logic of music stripping
def strip_music(inf, outf)
  header_end = "%%\n"
  header_closed = false

  inf.each_line do |l|
    if l == header_end then
      header_closed = true
    end

    if header_closed then
      outf.puts l.gsub(/\([^\(\)]*\)/, '')
    else
      outf.puts l
    end
  end
end

# very simple File output cache
class CachedO < StringIO
  def initialize(fname)
    @fname = fname
    super()
  end

  def close
    self.rewind
    File.open @fname, 'w' do |fw|
      fw.puts self.read
    end
  end
end

# logic of output stream determination
def get_output_stream(setup, input_file=nil)
  if setup[:overwrite] then
    return CachedO.open(input_file) # cache
  elsif setup[:output_file] != nil then
    return setup[:output_file]
  else
    return STDOUT
  end
end


if not ARGV.empty? then
  ARGV.each do |f|
    outf = get_output_stream(setup, f)
    File.open(f, 'r') do |fr|
      strip_music(fr, outf)
    end
    outf.close if outf != STDOUT
  end
else
  strip_music(STDIN, get_output_stream(setup))
end
