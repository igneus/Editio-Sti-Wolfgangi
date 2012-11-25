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



### Read arguments

hiramfile = ARGV.shift
unless hiramfile 
  hiramfile = 'hiram.yml'
end

unless File.exists? hiramfile
  raise "Input file '#{hiramfile}' not found."
end

### Read the project description file

require 'yaml'

# Wraps a YAML document and provides a clever interface to it's expected
# contents
class HiramFile
  def initialize(fname)
    @yaml = YAML.load(File.open(fname))
  end

  def main
    return @yaml['main']
  end

  def main?
    self.main != nil
  end

  def moretex
    return @yaml['moretex']
  end

  def moretex?
    @yaml.has_key?('moretex') && @yaml['moretex'].is_a?(Array)
  end

  def chants
    chs = []
    # expand wildcards
    @yaml['chants'].each do |c|
      if c.index '*' then
        chs += Dir[c]
      else
        chs << c
      end
    end

    return chs
  end

  def chants?
    self.chants != nil
  end
end

proj = HiramFile.new hiramfile

### Start building rake rules

require 'rake'

### Chants

chant_targets = []

if proj.chants? then
  chants = proj.chants
  chants.each do |c|
    c_t = c.gsub /\.gabc/, '.tex'
    chant_targets << c_t

    task_c = file c_t => [c] do |t|
      sh "gregorio #{t.prerequisites.first}"
    end

    task_c.invoke
  end
end

### Main file

if proj.main? then
  maintex = proj.main
  maintex_target = maintex.gsub /\.tex$/, '.pdf'

  maindeps = [maintex] + chant_targets

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
  end
end
