# hymnographus.rb MELODYFILE.gabc TEXTFILE.txt [OUTPUTFILE]

# the text file:
# * each verse is on a new line
# * an empty line means a beginning of a new stanza
# * syllables must be separated by /
# * part of a syllable enclosed in curly brackets {} will be italicized (contracted syllable)
# * syllable preceded by a < takes melody piece from the previous syllable
# * syllable ending with > analogically from the following syllable

class HymnMelody
  NOTES = %w(a b c d e f g h i j k l m n)

  def initialize
    @lines = []
    @key = nil
    @header = ""
  end

  attr_accessor :header
  attr_reader :lines
  attr_accessor :key

  def final
    last_neume = lines.last[-2]
    i = last_neume.size - 1
    while ! NOTES.include?(last_neume[i].downcase) do
      i -= 1
      if i <= 0 then
        raise "Final note not found in last neume '#{last_neume}'."
      end
    end
    return last_neume[i]
  end

  # amen melody in gregorio notation
  def amen
    f = NOTES.index(self.final)
    if f == nil then
      raise "Invalid final '#{self.final}'."
    end

    return "A("+NOTES[f]+NOTES[f+1]+NOTES[f]+")men.("+NOTES[f-1]+"."+NOTES[f]+".)"
  end

  def HymnMelody.load(filename)
    m = HymnMelody.new

    fr = File.open(filename, 'r')
    loop do
      l = fr.gets
      break if l == "%%\n"
      m.header += l
    end

    m.key = fr.gets

    while line = fr.gets do 
      ml = []

      while i = line.index('(') do
        j = line.index ')'
        ml << line.slice!(i..j)
      end

      m.lines << ml
    end

    return m
  end
end

class HymnText
  def initialize
    @stanzas = []
  end

  attr_reader :stanzas

  def HymnText.load(filename)
    t = HymnText.new

    s = Stanza.new

    File.open(filename, 'r').each do |line|
      # empty line - new stanza
      if line =~ /^\s*$/ then
        t.stanzas << s
        s = Stanza.new
        next
      end

      # words delimited by spaces, syllables by slashes
      sl = []
      a = b = 0
      
      while b < line.size do
        if line[b] == " " || line[b] == '/' || line[b] == "\n"then
          sl << line[a..b-1]

          if line[b] == " " then
            sl << " "
          end

          a = b + 1
          b = a
        else
          b += 1
        end
      end
      
      s.lines << sl
    end

    t.stanzas << s

    return t
  end

  class Stanza
    def initialize
      @lines = []
    end

    attr_reader :lines

    def set(melody)
      output = ""

      @lines.each_with_index do |textl,i|
        mell = melody.lines[i]

        begin
          texti = 0
          mi = 0
          begin
            neuma = mell[mi]
            
            if textl[texti] == ' ' then
              texti += 1
              output += " "
              redo
            end

            if texti >= textl.size then
              output += " "+mell.last
              break
            end

            syll = textl[texti]
            # superficial syllables - contracted
            syll = syll.gsub('{', '<i>').gsub('}', '</i>')

            # superficial syllables - notated
            if syll[0] == '<' then
              syll = syll[1..-1]
              neuma = mell[mi-1]
            elsif syll[-1] == '>' then
              syll = syll[0..-2]
              # just don't increment the mellody counter
            else
              mi += 1
            end

            output += syll
            output += neuma
            texti += 1
          end while mi < mell.size
          output += "\n"
        rescue
          STDERR.puts "Error occurred while setting line #{i}:"
          raise
        end
      end
      
      return output
    end # Stanza#set
  end
end

### main ########

options = {
  :outputfile => nil,
  :amen => true,
  :linebreaks => true
}

require 'optparse'
optparser = OptionParser.new do |opts|
  opts.on "-a", "--no-amen", "Don't append amen to the last stanza." do |f|
    options[:amen] = false
  end

  opts.on "-l", "--no-linebreaks", "Don't break lines after each stanza." do 
    options[:linebreaks] = false
  end
end
optparser.parse!

melodyfile = ARGV.shift
textfile = ARGV.shift

if ! ARGV.empty? then
  outputfile = ARGV.shift
  if outputfile == '-' then
    of = STDOUT
  else
    options[:outputfile] = outputfile
  end
end

if of then
  # nix
elsif options[:outputfile] then
  of = File.open options[:outputfile], 'w'
else
  ofn = textfile+'.gabc'
  of = File.open ofn, 'w'
end

melody = HymnMelody.load melodyfile
# p melody
text = HymnText.load textfile
# p text

if melody.lines.size != text.stanzas.first.lines.size then
  STDERR.puts "Warning: lines count in melody (#{melody.lines.size}) and text (#{text.stanzas.first.lines.size}) do not match."
end

of.puts melody.header
of.puts "%%"
of.puts melody.key
text.stanzas.each_with_index do |s,si|
  begin
    of.print s.set(melody)
  rescue
    STDERR.puts "Error occured while setting stanza #{si}."
    STDERR.puts
    STDERR.puts melody.inspect
    STDERR.puts
    STDERR.puts text.inspect
    STDERR.puts
    raise
  end

  if si != text.stanzas.size - 1 and options[:linebreaks] then
    of.puts " (z)"
  end
  of.puts
end

if options[:amen] then
  of.print melody.amen
end
of.puts " (::)"

of.close
