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

## Read the psalmfile

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
# Now we have all the (2 or 3) parts of the first verse in the array first_verse

## Read the patternfile

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

## Create output

class String
  def shift_psalm_syllable
    if self.empty? then
      return nil
    end

    # space
    if self[0] == ' ' then
      self[0] = ''
      return ' '
    end

    # syllable with an accent
    if self[0] == '[' then
      i = self.index ']'
      s = self[0..i]
      self[0..i] = ''
      return s
    end

    # other syllable
    i = self.index /[ \/\[]/ # space, slash or left square bracket
    unless i
      i = -1
      s = self[0..-1]
      self[0..-1] = ''
      return s
    end
    s = self[0..i-1]
    self[0..i-1] = ''
    if self[0] == '/' then
      self[0] = ''
    end
    return s
  end

  def to_psalm_syllables
    a = []
    while s = self.shift_psalm_syllable do
      a << s
    end
    return a
  end
end

begin of = STDOUT #fake
  
  of.puts "%%"
  of.puts key

  # initium
  initium.each do |n|
    s = first_verse[0].shift_psalm_syllable
    if s == ' ' then
      of.print s
      redo
    else
      of.print s
      of.print n
    end
  end

  # flex
  if first_verse.size == 3 then 
    loop do
      s = first_verse[0].shift_psalm_syllable
      break if s[0] == '['
      of.print s
      of.print initium.last
    end
    raise "Script not ready!!!!!!!! Fix it first!"
  end

  # mediation
  accents = mediation.select {|i| i.index 'r1' }.size
  # STDERR.puts accents
  preparatory_syllables = mediation.index {|i| i.index 'r1' } - 1
  # STDERR.puts preparatory_syllables
  medtext = first_verse[-2]
  medtext_split = medtext.to_psalm_syllables
  is = medtext_split.index {|s| s =~ /^\[/ }
  preparatory_syllables.times do
    is -= 1
    if medtext_split[is] == ' ' then
      redo
    end
  end
  medtext_split.each_with_index do |s,i|
    if i == is then
      # first preparatory syllable
      break
    end
    print s
    if s != ' ' then
      print mediation[0]
    end
  end

  

  of.puts
end
