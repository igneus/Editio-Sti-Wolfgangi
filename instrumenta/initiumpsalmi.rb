# -*- coding: utf-8 -*-
# Takes a psalm file (my .pslm format) and a psalmodic pattern (.gabc);
# produces a new .gabc containing the first verse of the psalm
# fitted to the pattern.
#
# initiumpsalmi.rb <options> [psalm.pslm] [pattern.gabc] [[outputfile]]

require 'optparse'

setup = {
  :inchoatio => true,
  :flex => false
}

optparse = OptionParser.new do|opts|
  opts.on "-i", "--no-inchoatio", "Don't set an inchoatio, start on the reciting tone" do
    setup[:inchoatio] = false
  end

  opts.on "-F", "--flex", "Provide the flex pattern if flex appears in the psalm" do
    setup[:flex] = true
  end
end

optparse.parse!

psalmfile = ARGV.shift
patternfile = ARGV.shift

if ! ARGV.empty? then
  of = ARGV.shift
  if of == '-' then
    outputfile = STDOUT
  else
    outputfile = of
  end
else
  i = File.basename(patternfile).index('.')
  output_ending = '-initium-'+File.basename(patternfile)[0..i-1]+'.gabc'
  outputfile = File.basename(psalmfile).gsub(/\.pslm$/, output_ending)
end

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

    def next_nonempty_syl(i)
      ss = self.syllables
      loop do
        i += 1
        if ! ss[i] then
          return nil
        end
        if ss[i] == ' ' || ss[i] == '*' then
          next
        end

        return ss[i]
      end
    end

    def nonempty_syls_before(before_i, how_many)
      j = 0
      i_now = before_i
      while j < how_many do
        i_now -= 1
        if self.syllables[i_now] != ' ' then
          j += 1
        end
      end
      return i_now
    end

  end # class PsalmVerse::VersePart

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

  def afterflex
    @third ? @second : @first
  end
  
  def has_flex?
    return @third != nil
  end
end

class PsalmodicPattern
  def initialize(key, initium, flex, mediation, termination)
    @key = key
    @initium = NoteGroup.new initium
    @flex = NoteGroup.new flex
    @mediation = NoteGroup.new mediation
    @termination = NoteGroup.new termination
  end

  class NoteGroup < Array
    def accents
      self.select {|n| n.index 'r1' }.size
    end
  
    def preparatory_syls
      first_accent = self.index {|n| n.index 'r1' }
      if first_accent.nil? then
        raise "Accent (r1) not found."
      end

      if movable_accent? then
        return first_accent - 2
      else 
        return first_accent - 1 # the first note is tenor, but the array are indexed from 0
      end
    end

    # says if the last accent is movable,
    # like in the mediation III.* and termination I.D2
    def movable_accent?
      # accent on the 2nd last (instead of 3rd last) syllable?
      self[-3].include? 'r1'
    end
  end

  attr_reader :key, :initium, :flex, :mediation, :termination

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

def psalm_contains_flex?(psalmfile)
  File.open psalmfile, 'r' do |fr|
    fr.each_line do |l|
      if l =~ /\+\s*$/ then
        return true
      end
    end
  end

  return false
end

# set mediation / termination
def set_verse_part(parttext, partmelody, text_offset, of)
  melody_i = 0
  text_i = 0 + text_offset

  ## tenor
  first_accent = (partmelody.accents == 2) ? 1 : 2
  if first_accent == 2 and 
      parttext.accents_count == 1 and
      partmelody.accents == 1 then
    first_accent = 1
  end
  last_tenor_syl = parttext.nonempty_syls_before(parttext.accent_pos(first_accent), partmelody.preparatory_syls) - 1 
  
  STDERR.puts
  parttext.syllables.each_with_index {|s,i| STDERR.print "#{i}:'#{s}', "}
  STDERR.puts
  STDERR.puts "first accent: #{parttext.accent_pos(first_accent)}"
  STDERR.puts "last tenor: #{last_tenor_syl} '#{parttext.syllables[last_tenor_syl]}' "
  STDERR.puts "preparatories: #{partmelody.preparatory_syls}"

  text_i.upto(last_tenor_syl) do |i|
    text_i = i
    s = parttext.syllables[text_i]
    if s == ' ' then
      of.print " "
      next
    else
      of.print strip_square_brackets s
      of.print partmelody[0] # tenor note
    end
  end
  text_i += 1
    
  ## preparatory syllables
  melody_i = 1
  partmelody.preparatory_syls.times do |i|
    s = strip_square_brackets parttext.syllables[text_i]
    text_i += 1
    if s == ' ' then
      of.print " "
      redo
    end
      
    of.print "<i>"
    of.print s
    of.print "</i>"
    of.print partmelody[melody_i]
    melody_i += 1
  end
    
  ## end-cadence

  partmelody.accents.times do |i|
    3.times do |j|
      unless parttext.syllables[text_i]
        break
      end
      
      s = parttext.syllables[text_i]
      if s == ' ' then
        text_i += 1
        of.print " "
        redo
      end
        
      if j == 1 && 
          (parttext.syllables[text_i+1].nil? || 
           ! parttext.next_nonempty_syl(text_i) ||
           parttext.next_nonempty_syl(text_i)[0] == '[') then
        # no superfluous syllable
        if parttext.syllables[text_i-1] == ' ' then
          of.print " "
        else
          of.print " -"
        end

        neume = partmelody[melody_i].dup

        # tones with a movable accent: remove the accent indication,
        # add the accent indication with a curly bracket
        if partmelody.movable_accent? && i == partmelody.accents - 1 then
          if j == 0 then
            neume.gsub! 'r', 'r[ocba:1;4mm]'
          elsif j == 1 then
            neume.gsub! 'r1', ''
          end
        end

        of.print neume+" "
        melody_i += 1
        next
      end
      
      of.print "<b>" if j == 0
      of.print strip_square_brackets(s)
      of.print "</b>" if j == 0

      neume = partmelody[melody_i].dup

      # tones with a movable accent: remove the accent indication,
      # add the accent indication with a curly bracket
      if partmelody.movable_accent? && i == partmelody.accents - 1 then
        if j == 0 then
          neume.gsub! 'r', 'r[ocba:1;4mm]'
        elsif j == 1 then
          neume.gsub! 'r1', ''
        end
      end

      of.print neume
      melody_i += 1
      text_i += 1
    end
  end
end




## Read the psalmfile
verse = PsalmVerse.read_from_psalmfile psalmfile

## Read the patternfile
psalmody = PsalmodicPattern.read_from_gabcfile patternfile

## Create output

if outputfile == STDOUT then
  of = outputfile
else
  of = File.open(outputfile, 'w')
end
  
of.puts "initial-style: 0;"
of.puts "%%"
of.puts psalmody.key

melody_i = 0
text_i = 0
  
## initium

if setup[:inchoatio] then
  initium = psalmody.initium
else
  # if the ichoatio is to be omitted, let the following routine
  # set a fake inchoatio made of one tenor note
  # (space is always added before the first note of the inchoatio
  # and we want this space always)
  initium = [psalmody.mediation.first]
end
  
initium.each_with_index do |n,i|
  s = verse.first.syllables[text_i]
  if s == ' ' then
    of.print " "
    text_i += 1
    redo
  else
    of.print s
    if i == 0 then
      # add space at the beginning
      of.print n.gsub("(", "( ")
    else
      of.print n
    end
    text_i += 1
  end
end

## flex
if verse.has_flex? then
  parttext = verse.first
  partmelody = psalmody.flex
  last_tenor_syl = parttext.accent_pos(1) - 2 

  text_i.upto(last_tenor_syl) do |i|
    text_i = i
    s = parttext.syllables[text_i]
    if s == ' ' then
      of.print " "
      next
    else
      of.print strip_square_brackets s
      of.print partmelody[0] # tenor note
    end
  end
  text_i += 1

  melody_i += 1
  3.times do |j|
    unless parttext.syllables[text_i]
      break
    end
      
    s = parttext.syllables[text_i]
    if s == ' ' then
      text_i += 1
      of.print " "
      redo
    end
        
    if j == 1 && 
        (parttext.syllables[text_i+1].nil? || 
         ! parttext.next_nonempty_syl(text_i) ||
         parttext.next_nonempty_syl(text_i)[0] == '[') then
      # no superfluous syllable
      if parttext.syllables[text_i-1] == ' ' then
        of.print " "
      else
        of.print " -"
      end
      of.print partmelody[melody_i]+" "
      melody_i += 1
      next
    end
      
    of.print "<b>" if j == 0
    of.print strip_square_brackets(s)
    of.print "</b>" if j == 0
    of.print partmelody[melody_i]
    melody_i += 1
    text_i += 1
  end

  of.puts "†(,)"

  text_i = 0
end

## mediatio & terminatio
[:afterflex, :last].each do |versepart|

  parttext = verse.send versepart
  partmelody = psalmody.send(versepart == :afterflex ? :mediation : :termination)
  offset = (versepart == :last ? 0 : text_i)

  set_verse_part parttext, partmelody, offset, of
  
  if versepart == :afterflex then
    of.puts " *(:)"
  else
    of.puts " (::)"
  end

end

## set the flex pattern after the verse
if (not verse.has_flex?) and 
    setup[:flex] and 
    psalm_contains_flex?(psalmfile) then

  flex_text = PsalmVerse::VersePart.new 'Sic [fléc]ti/tur. +'
  set_verse_part flex_text, psalmody.flex, 0, of

  of.puts " †(,) (::)"
end

of.puts

of.close
