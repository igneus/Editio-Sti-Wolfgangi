# There was utils_rake.rb with functions making use of many constants
# locating important files.
# I refactored them in a class that finds the paths.

require 'pathname'

# some functions not bound to the data owned by TaskGenerator
module Hiram::HiramUtils

  # generate a Rake task to compile a GABC file
  def gregorio(srcf)
    f2 = srcf.gsub(".gabc", ".tex")
    file f2 => [srcf] do
      wd = Dir.pwd
      chdir File.dirname(srcf)
      sh "gregorio #{File.basename srcf}"
      chdir wd
    end
    return f2
  end

  TONI_PSALMORUM = {
    'I.D' => [[2,0], [1,2]],
    'I.D2' => [[2,0], [1,2]],
    'Isoll.D2' => [[1,3], [1,2]],
    'I.f' => [[2,0], [1,2]],
    'I.g' => [[2,0], [1,2]],
    'I.g2' => [[2,0], [1,2]],
    'Isoll.D2' => [[1,3], [1,2]],
    'Isoll.g' => [[1,3], [1,2]],
    'II.D' => [[1,0], [1,1]],
    'IIsoll.D' => [[1,3], [1,1]],
    'II.A' => [[1,0], [1,1]],
    'IIsoll.A' => [[1,3], [1,1]],
    'III.a' => [[2,0], [2,0]],
    'III.a3' => [[2,0], [2,0]],
    'III.b' => [[2,0], [2,0]],
    'IV.E' => [[1,2], [1,3]],
    'IV.A' => [[1,2],[1,3]],
    'VI.F' => [[1,1], [1,2]],
    'VII.a' => [[2,0], [2,0]],
    'VII.c' => [[2,0], [2,0]],
    'VII.c2' => [[2,0], [2,0]],
    'VII.d' => [[2,0], [2,0]],
    'VIIsoll.a' => [[2,0], [2,0]],
    'VIII.G' => [[1,0], [1,2]],
    'VIII.c' => [[1,0], [1,2]],
    'VIII.G*' => [[1,0], [1,2]],
    'VIIIsoll.G' => [[1,3], [1,2]],
    'VIIIsoll.G2' => [[1,3], [1,2]],
    'per' => [[1,3], [1,1]],
    'dir' => [[1,2], [1,0]]
  }

  # takes a psalmtone (String like 'I.g') and returns options
  # for psalmpreprocessor.rb to point a psalm for this tone
  def options_accents(psalmtone)
    if psalmtone.is_a? Array then
      tone_spec = psalmtone
    else
      if TONI_PSALMORUM[psalmtone] == nil then
        raise ArgumentError, "Unknown psalm tone '#{psalmtone}'."
      end

      tone_spec = TONI_PSALMORUM[psalmtone]
    end

    accents = 
      tone_spec[0][0].to_s + ':' + 
      tone_spec[1][0].to_s
    preps = 
      tone_spec[0][1].to_s + ':' + 
      tone_spec[1][1].to_s
    
    return "--accents #{accents} --preparatory-syllables #{preps}"
  end
end


class Hiram::TaskGenerator

  include Rake::DSL
  include Hiram::HiramUtils

  RUBY_COMMAND = 'ruby'

  def initialize(settings)
    here = Pathname.new Dir.pwd

    @instrumenta_dir = Pathname.new(__FILE__).dirname.dirname
    @editio_dir = @instrumenta_dir.dirname

    @instrumenta_dir = @instrumenta_dir.relative_path_from(here).to_s+'/'
    @editio_dir = @editio_dir.relative_path_from(here).to_s+'/'

    @psalm_preprocessor = 'pslm.rb'
    @psalmtones_dir = settings[:psalmtones_dir]
    @psalms_dir = settings[:psalms_dir]
    @czech_psalms_dir = settings[:czech_psalms_dir]

    @default_psalm_options = "--join --accents-style bold --skip-title "
    @output_dir = './temporalia/'
  end

  attr_accessor :default_psalm_options
  attr_accessor :output_dir

  def psalm_file(psalm, input_dir)
    if psalm.include? '/' or File.exist? psalm then
      return psalm
    else
      return input_dir+"/"+psalm
    end
  end

  # General function generating a Rake task to point a psalm text
  def genpsalm_universal(zalm, outputname, options, output_dir=@output_dir, input_dir=@psalms_dir)
    wd = Dir.pwd
    
    syrovy = psalm_file(zalm, input_dir)
    peceny = output_dir + outputname

    # expand a fake option (this solution is pretty dirty!)
    append = ''
    if options.include? '--gloriapatri' then
      options.gsub!('--gloriapatri', "")
      append = ' ../'+psalm_file('gloriapatri.pslm', input_dir)
    end

    file peceny => [syrovy] do
      chdir output_dir
      sh "#{@psalm_preprocessor} #{options} ../#{syrovy} #{append}"
      chdir wd
    end
    return peceny
  end

  # Rake task to point a psalm text
  def genpsalm(zalm, outputname, options=@default_psalm_options)
    genpsalm_universal(zalm, outputname, options, @output_dir, @psalms_dir)
  end

  # translations not intended to be sung: no pointing at all, no title, ...
  @@czech_psalm_options = "--accents 0:0 --skip-title --no-paragraph "

  # Rake task to process a Czech psalm translation
  def genczechpsalm(zalm, outdir=nil)
    # find in which set translation of this psalm is
    unless @czech_psalms_dir.is_a? Array
      @czech_psalms_dir = [@czech_psalms_dir]
    end
    input_dir = @czech_psalms_dir.find do|d|
      File.exists? d+'/'+zalm
    end
    
    unless input_dir
      raise "Translation of the psalm '#{zalm}' not found."
    end

    of = zalm.gsub(".pslm", "-boh.tex")
    if outdir then
      of = outdir + '/' + of
    end
    ofop = "--output "+of+" "
    syrovy = input_dir+'/'+zalm
    of_fullpath = @output_dir+of
    file of_fullpath => [syrovy] do
      wd = Dir.pwd
      chdir @output_dir
      sh "#{@psalm_preprocessor} #{ofop} #{@@czech_psalm_options} ../#{syrovy}"
      chdir wd
    end
    return of_fullpath
  end

  # Rake task to notate first verse of a psalm
  def geninitium(psalm, tone, inchoatio=true, options='', outdir=nil)
    unless tone.is_a? String
      tone = ''
    end

    ntone = tone
    if i = ntone.index('.') then
      ntone = ntone[0..i-1].downcase+'-'+ntone[i+1..-1]
    end
    patternfile = "#{@psalmtones_dir}#{ntone}-auto.gabc"
    if not File.exist?(patternfile) then
      raise "Psalm tone file #{patternfile} not found. (#{patternfile})"
    end

    
    psalmfile = psalm_file(psalm, @psalms_dir)
  
    i = File.basename(patternfile).index('.')
    output_ending = '-initium-'+File.basename(patternfile)[0..i-1]+'.gabc'
    outputfile = File.basename(psalmfile).gsub(/\.pslm$/, output_ending)
    if outdir then
      outputfile = outdir + '/' + outputfile
    else
      outputfile = @output_dir + '/' + outputfile
    end
    options += " --output #{outputfile}"

    unless inchoatio
      options += ' --no-inchoatio'
    end

    initium_tool = @instrumenta_dir+'initiumpsalmi.rb'

    file outputfile => [psalmfile, patternfile, initium_tool] do
      sh "ruby #{initium_tool} #{options} #{psalmfile} #{patternfile}"
    end

    return gregorio(outputfile)
  end

  def genhymn(textfile, musicfile, options)
    basename = File.basename textfile
    i = basename.rindex '-'
    ii = basename.rindex '.'
    out = "hymnus-"+basename[i+1..ii-1]+".gabc"

    hymnographus = @instrumenta_dir + 'hymnographus.rb'
    compiled_hymn = @output_dir+out
    file compiled_hymn => [textfile, musicfile, hymnographus] do |t|
      sh "#{RUBY_COMMAND} #{hymnographus} #{options} #{t.prerequisites[1]} #{t.prerequisites[0]} #{t.name}"
    end

    return gregorio(compiled_hymn)
  end
end
