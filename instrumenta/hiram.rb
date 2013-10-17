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
require 'optparse'

module Hiram
end

editio_instrumenta_dir = File.dirname __FILE__

require editio_instrumenta_dir+'/hiram/taskgenerator.rb'
require editio_instrumenta_dir+'/hiram/hiramfile.rb'

module Hiram
  class Hiram
    include Rake::DSL
    include HiramUtils

    def initialize
      @hiramfile = 'hiram.yml'
      @action = :run_main # also possible: :run_selected, :show_tasks
      @selected_tasks = []

      @proj = nil # loaded hiramfile
      read_options

      editio_dir = Pathname.new(__FILE__).dirname.dirname.to_s

      # default values of settings which might be specified in the hiramfile
      @default_settings = {
        'psalms-dir' => editio_dir+'/psalmi/amon33/',
        'psalmtones-dir' => editio_dir+'/tonipsalmorum/arom12/',
        # this may be either a single path or an Array of paths
        # searched for a psalm in a given order
        'translations-dir' => [
                               editio_dir+'/bohemice_psalmi/Hejcl1922', 
                               editio_dir+'/bohemice_psalmi/DMC199x', 
                               editio_dir+'/bohemice_psalmi/Pavlik'
                              ],
        'hymnographus-options' => [],
        'initia-options' => [],
        # should the preprocessed psalms be in subdirectories?
        'temporalia-structured' => false
      }
      read_hiramfile

      @taskgen = TaskGenerator.new({
                                     :psalmtones_dir => @proj.settings['psalmtones-dir'],
                                     :psalms_dir => @proj.settings['psalms-dir'],
                                     :czech_psalms_dir => @proj.settings['translations-dir']
                                   })
    end

    def run
      make_dirs

      load_chant_targets
      load_psalm_targets
      load_hymn_targets
      load_main_target

      case @action 

      when :run_main
        begin
          Rake::Task['main'].invoke
        rescue RuntimeError => re
          STDERR.puts
          STDERR.puts "build ERROR: "+re.message
          STDERR.puts
          # Rake::Task.tasks.each {|t| p t }
        end

      when :run_selected
        @selected_tasks.each do |tname|
          Rake::Task[tname].invoke
        end

      when :show_tasks
        puts "Available tasks:\n\n"
        Rake::Task.tasks.each do |task|
          # only show commented tasks
          if task.comment then
            puts task.name.ljust(10) + task.comment.to_s
          end
        end

      when :dump_tasks
        Rake::Task.tasks.each do |task|
          p task
        end
      end
    end

    private

    def read_options
      optparser = OptionParser.new do |opts|
        opts.on "-f", "--hiramfile FILE", "Use FILE as the hiramfile." do |f|
          @hiramfile = f
        end

        opts.on "-T", "--tasks", "Show available tasks" do 
          @action = :show_tasks
        end

        opts.on "-d", "--dump", "Dump tasks for debugging" do 
          @action = :dump_tasks
        end
      end
      optparser.parse!

      unless ARGV.empty?
        @action = :run_selected
        @selected_tasks = ARGV
      end
    end

    def read_hiramfile
      unless File.exists? @hiramfile
        raise "Input file '#{@hiramfile}' not found."
      end

      @proj = HiramFile.new @hiramfile, @default_settings
    end

    def load_chant_targets
      @chant_targets = []

      if @proj.chants? then
        chants = @proj.chants
        chants.each do |c|
          c_t = c.gsub /\.gabc/, '.tex'
          @chant_targets << c_t

          task_c = file c_t => [c] do |t|
            gregorio t.prerequisites.first
          end

          # task_c.invoke
        end

        task 'chants' => @chant_targets
        Rake::Task['chants'].comment = "compile all necessary chants notated in gregorio"
      end
    end

    

    def load_psalm_targets
      @psalms_targets = []
      @initia_targets = []
      
      unless @proj.psalms
        return
      end

      @psalm_subdirnames = {}
      if @proj.settings['temporalia-structured'] then
        # create directories for preprocessed psalms
        @proj.psalms.each_key do |k|
          @psalm_subdirnames[k] = k.gsub(/[\.,]/, '').gsub(' ', '-').downcase
          unless File.directory?('temporalia/' + @psalm_subdirnames[k])
            Dir.mkdir('temporalia/' + @psalm_subdirnames[k])
          end
        end
      end

      @proj.psalms.each_pair do |section_name, section|
        section.each_pair do |psalm, tone|
          if psalm.is_a? String and psalm.index(',') then
            options = []
            if psalm.index(';') then
              psalm, options = psalm.split ';'
              options = options.split(/[\s,]+/)
            end
            psalms = psalm.split(/\s*,\s*/)
            psalms.each_with_index do |p,i|
              create_psalm_task(p, tone, true, (i == 0), (i >= psalms.size-1), options, section_name)
            end
          else
            create_psalm_task(psalm, tone, 
                              false, false, false, [], # defaults repeated
                              section_name)
          end
        end
      end  

      task 'initia' => @initia_targets
      Rake::Task['initia'].comment = "Generate notated first verse of each psalm"

      task 'psalms' => @psalms_targets
      Rake::Task['psalms'].comment = "Point psalm texts"  
    end

    # helper for the previous method
    def create_psalm_task(psalm, tone, ingroup=false, firstingroup=false, lastingroup=false, psalm_options=[], hour='')
      if tone.is_a? String then
        tonesuff =  '-' + tone.downcase.gsub('.', '-')
      else
        tonesuff = ''
      end

      

      if psalm.is_a? String and File.exist? psalm then
        psfname = psalm
        psoutname = File.basename(psfname).gsub(/\.pslm$/, '.tex')
      elsif psalm.is_a? Fixnum or
        (psalm.is_a? String and psalm =~ /^\d+/) then
        psfname = 'ps' + psalm.to_s + '.pslm'
        psoutname = 'ps' + psalm.to_s + tonesuff + '.tex'
      else
        psfname = psalm + '.pslm'
        psoutname = psalm + tonesuff + '.tex'
      end

      outdir = nil
      if @proj.settings['temporalia-structured'] then
        outdir = @psalm_subdirnames[hour]
        psoutname = outdir + '/' + psoutname
      end

      options = @taskgen.default_psalm_options + 
        options_accents(tone) +
        " --output #{psoutname} "

      skip = (psalm == 'magnificat') ? 2 : 1
      if ingroup == false or firstingroup == true then
        options += "--skip-verses #{skip} "
      end

      if psalm != 'dan3' and 
          (ingroup == false or 
           ! psalm_options.include?('singledoxology') or 
           lastingroup == true) then
        options += "--gloriapatri "
      end
      
      @psalms_targets << @taskgen.genpsalm(psfname, psoutname, options)

      begin
        @psalms_targets << @taskgen.genczechpsalm(psfname, outdir)
      rescue RuntimeError => re
        STDERR.puts "ERROR: translation not generated for psalm '#{psfname}': "+re.message
      end

      if psalm != 'magnificat' then
        inchoatio = ((not ingroup) or firstingroup)
        begin
          opts = @proj.settings['initia-options'].collect {|o| "--#{o}"}.join(" ")
          @initia_targets << @taskgen.geninitium(psfname, tone, inchoatio, opts, @taskgen.output_dir + '/' + outdir)
        rescue RuntimeError => re
          STDERR.puts "ERROR: initium not generated for psalm '#{psfname}': "+re.message
        end
      end
    end

    def load_hymn_targets
      @hymn_targets = []

      if @proj.hymns? then
        @proj.hymns.each do |h|
          textus = h[0]
          musica = h[1]
          options = h[2] || @proj.settings['hymnographus-options'].collect {|s| "--#{s}"}.join(' ')

          @hymn_targets << @taskgen.genhymn(textus, musica, options)
        end

        task 'hymns' => @hymn_targets
        Rake::Task['hymns'].comment = "Set hymn texts to their respective tunes"
      end
    end

    def load_main_target
      if @proj.main? then
        maintex = @proj.main
        unless maintex.is_a? Array
          maintex = [maintex]
        end

        main_targets = []

        maintex.each do |m|
          target = m.gsub /\.tex$/, '.pdf'
          main_targets << target

          maindeps = [m] + 
            @chant_targets + @initia_targets + @psalms_targets + @hymn_targets

          if @proj.moretex? then
            maindeps += @proj.moretex
          end

          file target => maindeps do |t|
            2.times { sh "lualatex -interaction=nonstopmode #{t.prerequisites.first}" }
          end
        end

        task 'main' => main_targets
        Rake::Task['main'].comment = "Run all tasks and finally compile the main book"  
      end
    end

    def make_dirs
      unless File.directory? 'temporalia'
        Dir.mkdir 'temporalia'
      end
    end
  end # class Hiram
end # module Hiram

if $0 == __FILE__ then
  Hiram::Hiram.new.run
end
