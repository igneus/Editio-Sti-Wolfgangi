def genpsalm_universal(zalm, options="", output_dir, input_dir)
  wd = Dir.pwd
  syrovy = input_dir+"/"+zalm
  peceny = output_dir+'/'+zalm.gsub(/\.pslm/, '')+'.tex'
  file peceny => [syrovy, PSALM_PREPROCESSOR] do
    chdir output_dir
    sh "#{RUBY_COMMAND} ../#{PSALM_PREPROCESSOR} #{options} ../#{syrovy}"
    chdir wd
  end
  return peceny
end

def genpsalm(zalm, options="", output_dir=TMP_DIR, input_dir=PSALMS_DIR)
  genpsalm_universal(zalm, options, output_dir, input_dir)
end

def genczechpsalm(zalm, options="", output_dir=TMP_DIR, input_dir=CZECH_PSALMS_DIR+"/Hejcl1922/")
  of = zalm.gsub(".pslm", "-boh.tex")
  ofop = "--output "+of+" "
  wd = Dir.pwd
  syrovy = input_dir+zalm
  of_fullpath = output_dir+'/'+of
  file of_fullpath => [syrovy, PSALM_PREPROCESSOR] do
    chdir output_dir
    sh "#{RUBY_COMMAND} ../#{PSALM_PREPROCESSOR} #{ofop} #{options} ../#{syrovy}"
    chdir wd
  end
  return of_fullpath
end

def genzalmsuff(zalm, options="", suff="aaa", adresar=TMP_DIR)
  wd = Dir.pwd
  syrovy = PSALMS_DIR+"/"+zalm
  peceny = adresar+"/"+zalm.gsub(/\.pslm/, '')+'-'+suff+'.tex'
  file peceny => [syrovy, PSALM_PREPROCESSOR] do
    chdir adresar
    sh "#{RUBY_COMMAND} ../#{PSALM_PREPROCESSOR} -o #{File.basename(peceny)} #{options} ../#{syrovy}"
    chdir wd
  end
  return peceny
end

def gregorio(srcf)
  f2 = srcf.gsub(".gabc", ".tex")
  file f2 => [srcf] do
    sh "gregorio #{srcf}"
  end
  return f2
end

def geninitium(psalm, tone, directory=TMP_DIR+"/")
  ntone = tone
  if i = ntone.index('.') then
    ntone = ntone[0..i-1].downcase+'-'+ntone[i+1..-1]
  end
  patternfile = PSALMTONES_DIR+"/"+ntone+'-auto.gabc'

  psalmfile = PSALMS_DIR + '/' + (psalm.is_a?(Fixnum) ? "ps#{psalm}" : psalm) + '.pslm'
  
  i = File.basename(patternfile).index('.')
  output_ending = '-initium-'+File.basename(patternfile)[0..i-1]+'.gabc'
  outputfile = File.basename(psalmfile).gsub(/\.pslm$/, output_ending)

  initium_tool = TOOLS_DIR+'/initiumpsalmi.rb'

  file directory+outputfile => [psalmfile, patternfile, initium_tool] do
    wd = Dir.pwd
    chdir directory
    sh "ruby ../#{initium_tool} ../#{psalmfile} ../#{patternfile}"
    chdir wd
  end

  return gregorio(directory+outputfile)
end

def options_accents(psalmtone)
  accents = "#{TONI_PSALMORUM[psalmtone][0][0]}:#{TONI_PSALMORUM[psalmtone][1][0]}"
  preps = "#{TONI_PSALMORUM[psalmtone][0][1]}:#{TONI_PSALMORUM[psalmtone][1][1]}"

  return "--accents #{accents} --preparatory-syllables #{preps}"
end


$gloriapatri = File.readlines(PSALMS_DIR + '/gloriapatri.pslm').join ""

$options_common = "--accents-style bold --append \"#{$gloriapatri}\" --skip-verses 1 "
$options_magnificat = $options_common.gsub "--skip-verses 1", "--skip-verses 2"
$options_translation = "--accents 0:0 --title-pattern \" \" --no-paragraph "
