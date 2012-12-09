# hymnographus.rb MELODYFILE.gabc TEXTFILE.txt [OUTPUTFILE]

class HymnMelody
  NOTES = %w(a b c d e f g h i j k l m n)

  def initialize
    @lines = []
    @key = nil
  end

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
    begin
      l = fr.gets 
    end while l != "%%\n"

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

        texti = 0
        mell.each do |neuma|
          if textl[texti] == ' ' then
            texti += 1
            output += " "
            redo
          end

          if texti >= textl.size then
            output += " "+mell.last
            break
          end

          output += textl[texti].gsub('{', '<i>').gsub('}', '</i>')
          output += neuma
          texti += 1
        end
        output += "\n"
      end
      
      return output
    end # Stanza#set
  end
end

### main ########

options = {
  :outputfile => nil,
  :makeamen => true
}

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

of.puts "%%"
of.puts melody.key
text.stanzas.each_with_index do |s,si|
  of.print s.set(melody)
  if si != text.stanzas.size - 1 then
    of.puts " (z)"
  end
  of.puts
end

of.puts melody.amen+" (::)"

of.close
