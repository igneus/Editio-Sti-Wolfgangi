# Takes a psalm file (my .pslm format) and a psalmodic pattern (.gabc);
# produces a new .gabc containing the first verse of the psalm
# fitted to the pattern.
#
# initiumpsalmi.rb [psalm.pslm] [pattern.gabc]

psalmfile = ARGV.shift
patternfile = ARGV.shift

i = File.basename(patternfile).index('.')
output_ending = '-initium-'+File.basename(patternfile)[0..i-1]+'.gabc'
outputfile = File.basename(psalmfile).gsub(/\.pslm$/, output_ending)

first_verse = []

class PsalmVerse
  def initialize(first, second, third=nil)
    @first = VersePart.new first
    @second = VersePart.new second
    @third = third ? VersePart.new(third) : nil
  end
  
  class VersePart < String
    def initialize(str)
      super(str)
    end
    
    def syllables
      i = 0
      syls = []

      loop do
        # end reached
        if i == (self.size - 1) then
          break
        
        # space
        elsif self[i] == ' ' then
          i += 1
          syls << ' '
        
        # accentuated syllable
        elsif self[i] == '[' then
          j = self.index(']', i+1)
          syls << self[i..j]
          i = j+1
        
        # other syllable
        else
          j = self.index(/[ \/\[]/, i+1) # space, slash or left square bracket
          unless j
            j = -1
            s = self[i..-1]
            syls << s
            break
          end
          
          s = self[i..j-1]
          syls << s
          i = j
          if self[i] == '/' then
            i += 1
          end
        end          
      end

      return syls
    end
    
    def nonspace_syllables
      return self.syllables.delete {|s| s == ' ' }
    end
    
    def accents_count
      self.syllables.select {|s| s[0] == '[' }.size
    end
    
    def accent_pos(accent_num=1)
      ss = self.syllables
      y = 0
      i = ss.index {|s| 
        if s[0] == '[' then
          y += 1
        end
        if y == accent_num then
          true
        else
          false
        end
      }
      unless i
        raise "This verse part doesn't have #{accent_num} accents."
      end
      
      return i
    end
  end

  def PsalmVerse.read_from_psalmfile(psalmfile)
    first_verse = []
    File.open(psalmfile, 'r') do |pf|
      begin
        l = pf.gets
      end while l =~ /^\s*#/
      # now we have the title.
      begin
        l = pf.gets.rstrip
      end while l =~ /^\s*#/ || l =~ /^\s*$/
      # now we have the first half - verse:
      begin
        if i = l.index('#') then
          l = l[0..i-1]
        end
        first_verse << l
        begin
          l = pf.gets.rstrip
        end while l =~ /^\s*#/
      end while first_verse.last =~ /[\*\+]\s*$/
    end
    return PsalmVerse.new(*first_verse)
  end

  attr_reader :first, :second, :third
  
  def last
    @third ? @third : @second
  end
  
  def has_flex?
    return @third != nil
  end
end

class PsalmodicPattern
  def initialize(key, initium, flex, mediation, termination)
    @key = key
    @initium = initium
    @flex = flex
    @mediation = mediation
    @termination = termination
  end

  attr_reader :key, :initium, :flex, :mediation, :termination
  
  def mediation_accents
    @mediation.select {|n| n.index 'r1' }.size
  end
  
  def mediation_preparatory_syls
    first_accent = @mediation.index {|n| n.index 'r1' }
    return first_accent - 1 # the first note is tenor, but the array are indexed from 0
  end
  
  def termination_accents
    @termination.select {|n| n.index 'r1' }.size
  end
  
  def termination_preparatory_syls
    first_accent = @termination.index {|n| n.index 'r1' }
    return first_accent - 1 # the first note is tenor
  end

  def PsalmodicPattern.read_from_gabcfile(patternfile)
    key = initium = flex = mediation = termination = ''

    File.open(patternfile, 'r') do |ptf|
      begin
        l = ptf.gets
        raise unless l
      end while l !~ /^\s*%%\s*$/
      begin
        l = ptf.gets.rstrip
      end while l =~ /^\s$/
      
      key = ptf.gets.rstrip
      initium = ptf.gets.rstrip.split(' ')
      flex = ptf.gets.rstrip.split(' ')
      mediation = ptf.gets.rstrip.split(' ')
      termination = ptf.gets.rstrip.split(' ')
    end

    return PsalmodicPattern.new(key, initium, flex, mediation, termination)
  end
end

def strip_square_brackets(str)
  s = str.dup
  s[0] = '' if s[0] == '['
  s[-1] = '' if s[-1] == ']'
  return s
end

## Read the psalmfile
verse = PsalmVerse.read_from_psalmfile psalmfile

## Read the patternfile
psalmody = PsalmodicPattern.read_from_gabcfile patternfile

## Create output

File.open(outputfile, 'w') do |of|
  
  of.puts "initial-style: 0;"
  of.puts "%%"
  of.puts psalmody.key

  melody_i = 0
  text_i = 0
  
  ## initium
  psalmody.initium.each do |n|
    s = verse.first.syllables[text_i]
    if s == ' ' then
      print " "
      text_i += 1
      redo
    else
      print s
      print n
      text_i += 1
    end
  end

  if verse.has_flex? then
    raise "Finish the script first! This functionality is still missing."
  else
    ## tenor
    first_accent = (psalmody.mediation_accents == 2) ? 1 : 2
    text_i.upto(verse.first.accent_pos(first_accent) - psalmody.mediation_preparatory_syls - 1) do |i|
      text_i = i
      s = strip_square_brackets verse.first.syllables[text_i]
      if s == ' ' then
        of.print " "
        next
      else
        of.print s
        of.print psalmody.mediation[0] # tenor note
      end
    end
    text_i += 1
    
    ## preparatory syllables of the mediation
    melody_i = 1
    psalmody.mediation_preparatory_syls.times do |i|
      s = strip_square_brackets verse.first.syllables[text_i]
      text_i += 1
      if s == ' ' then
        of.print " "
        redo
      end
      
      of.print s
      of.print psalmody.mediation[melody_i]
      melody_i += 1
    end
    
    ## mediation
    psalmody.mediation_accents.times do |i|
      3.times do |j|
        unless verse.first.syllables[text_i]
          break
        end
      
        s = strip_square_brackets verse.first.syllables[text_i]
        if s == ' ' then
          text_i += 1
          of.print " "
          redo
        end
        
        if j == 2 && s[0] == '[' then
          # no superfluous syllable
          melody_i += 1
          break
        end
        
        of.print strip_square_brackets(s)
        of.print psalmody.mediation[melody_i]
        melody_i += 1
        text_i += 1
      end
    end
  end
  
  of.puts " (:)"
  
  ## tenor
  melody_i = 0
  text_i = 0
  
  first_accent = (psalmody.termination_accents == 2) ? 1 : 2
  text_i.upto(verse.last.accent_pos(first_accent) - psalmody.termination_preparatory_syls - 2) do |i|
    text_i = i
    s = strip_square_brackets verse.last.syllables[text_i]
    if s == ' ' then
      of.print " "
      next
    else
      of.print s
      of.print psalmody.termination[0] # tenor note
    end
  end
  text_i += 1
  
  ## preparatory syllables of the termination
  melody_i = 1
  psalmody.termination_preparatory_syls.times do |i|
    s = strip_square_brackets verse.last.syllables[text_i]
    text_i += 1
    if s == ' ' then
      of.print " "
      redo
    end
    
    of.print s
    of.print psalmody.termination[melody_i]
    melody_i += 1
  end
  
  ## mediation
  psalmody.termination_accents.times do |i|
    3.times do |j|
      unless verse.last.syllables[text_i]
        break
      end
      
      s = strip_square_brackets verse.last.syllables[text_i]
      if s == ' ' then
        text_i += 1
        of.print " "
        redo
      end
      
      if j == 2 && s[0] == '[' then
        # no superfluous syllable
        melody_i += 1
        break
      end
      
      of.print strip_square_brackets(s)
      of.print psalmody.termination[melody_i]
      melody_i += 1
      text_i += 1
    end
  end
  
  of.puts " (::)"

  of.puts
end
