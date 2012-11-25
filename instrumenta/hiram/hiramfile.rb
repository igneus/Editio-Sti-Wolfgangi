# Wraps a YAML document and provides a clever interface to it's expected
# contents
class Hiram::HiramFile
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

  def psalms
    return @yaml['psalms']
  end

  def psalms?
    self.psalms != nil
  end
end
