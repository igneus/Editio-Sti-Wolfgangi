# Wraps a YAML document and provides a clever interface to it's expected
# contents
class Hiram::HiramFile
  def initialize(fname, default_settings={})
    @yaml = YAML.load(File.open(fname))
    @default_settings = default_settings
    @settings = if @yaml.has_key?('settings') then
                  @default_settings.dup.update(@yaml['settings'])
                else
                  @default_settings.dup
                end
  end

  attr_reader :settings

  def main
    return @yaml['main']
  end

  def main?
    self.main != nil
  end

  def moretex
    return expand_wildcards(@yaml['moretex'])
  end

  def moretex?
    @yaml.has_key?('moretex') && @yaml['moretex'].is_a?(Array)
  end

  def chants
    return expand_wildcards(@yaml['chants'])
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

  def hymns
    return @yaml['hymns']
  end

  def hymns?
    self.hymns != nil
  end

  private

  def expand_wildcards(ar)
    expanded = []
    # expand wildcards
    ar.each do |c|
      if c.index '*' then
        expanded += Dir[c]
      else
        expanded << c
      end
    end

    return expanded
  end
end
