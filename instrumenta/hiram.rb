# (Hiram was a craftman working for the king Salomon)
# 
# This script generates project building rules from a yaml description.
# Each chant booklet project (at least in the Conventus series) has
# a very simple structure:
#
# - a main latex file + several more
# - several gabc files with scores
# - several psalms to be processed - text pointed and the first verse notated
# - some hymns to be notated
# 
# Run hiram in the project directory. It will look for hiram.yml (or other
# filename specified), build and execute Rake rules according to its
# description.

require 'yaml'
require 'rake'

module Hiram
end

editio_instrumenta_dir = File.dirname __FILE__

require editio_instrumenta_dir+'/hiram/taskgenerator.rb'
require editio_instrumenta_dir+'/hiram/hiramfile.rb'

include Hiram

### Read arguments

hiramfile = ARGV.shift
unless hiramfile 
  hiramfile = 'hiram.yml'
end

unless File.exists? hiramfile
  raise "Input file '#{hiramfile}' not found."
end

### Read the project description file

proj = HiramFile.new hiramfile
taskgen = TaskGenerator.new

### Chants

chant_targets = []

if proj.chants? then
  chants = proj.chants
  chants.each do |c|
    c_t = c.gsub /\.gabc/, '.tex'
    chant_targets << c_t

    task_c = file c_t => [c] do |t|
      gregorio t.prerequisites.first
    end

    # task_c.invoke
  end
end

### Psalms - text pointing, initia

initia_targets = []
psalms_targets = []

proj.psalms.each_value do |section|
  section.each_pair do |psalm, tone|
    tonesuff =  '-' + tone.downcase.gsub('.', '-')
    if psalm.is_a? Fixnum ||
        (psalm.is_a? String && psalm =~ /^\d+/) then
      psfname = 'ps' + psalm.to_s + '.pslm'
      psoutname = 'ps' + psalm.to_s + tonesuff + '.tex'
    else
      psfname = psalm + '.pslm'
      psoutname = psalm + tonesuff + '.pslm'
    end

    options = taskgen.default_psalm_options + 
      options_accents(tone) +
      " --output #{psoutname} "

    if psalm == 'magnificat' then
      options.gsub! "--skip-verses 1", "--skip-verses 2"
    end

    psalms_targets << taskgen.genpsalm(psfname, psoutname, options)

    psalms_targets << taskgen.genczechpsalm(psfname)

    if psalm != 'magnificat' then
      initia_targets << taskgen.geninitium(psfname, tone)
    end
  end
end

### Main file

if proj.main? then
  maintex = proj.main
  maintex_target = maintex.gsub /\.tex$/, '.pdf'

  maindeps = [maintex] + chant_targets + initia_targets + psalms_targets

  if proj.moretex? then
    maindeps += proj.moretex
  end

  task_main = file maintex_target => maindeps do |t|
    2.times { sh "lualatex -interaction=nonstopmode #{t.prerequisites.first}" }
  end

  begin
    task_main.invoke
  rescue RuntimeError => re
    STDERR.puts
    STDERR.puts "build ERROR: "+re.message
    STDERR.puts
    # Rake::Task.tasks.each {|t| p t }
  end
end
