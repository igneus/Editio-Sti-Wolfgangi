# creates a LuaLatex document containing all the chants from the given directory

# arguments: path of the directory + (voluntarily) output file name

OUTFN_DEFAULT = 'omnescantus.tex'

chantsdir = ARGV[0]
outfn = ARGV[1] || OUTFN_DEFAULT

Dir.chdir chantsdir

chants = Dir['*.gabc']
chants.sort!

File.open(outfn, 'w') do |f|

  f.puts <<EOS

% LuaLaTeX

\\documentclass[a4paper, 12pt]{article}
\\usepackage[latin]{babel} 
\\usepackage[left=2cm, right=2cm, top=2cm, bottom=2cm]{geometry}

\\usepackage{fontspec}
\\setmainfont{Junicode}

% for gregorio
\\usepackage{luatextra}
\\usepackage{graphicx} % support the \includegraphics command and options
\\usepackage{gregoriotex} % for gregorio score inclusion

\\begin{document}

EOS

  chants.each do |c|
    # info from the gabc file
    File.open(c, 'r') do |fc|
      f.puts
      ctexified = c.gsub('_', '\_')
      f.puts "\\textbf{#{ctexified}}"
      f.puts
      while l = fc.gets do
        break if l =~ /^%%\s*$/
        # the gsub is a bit unintuitive ... it simply sescapes
        # some special latex chars with a _single_ backslash
        f.puts '\\noindent '+l.rstrip.gsub(/([_%&])/, '\\\\\1') + '\\\\'
      end
    end

    f.puts '\\vspace{1cm}'

    cc = c.gsub(/\.gabc$/, '.tex')

    # the score
    f.puts "\\includescore{#{cc}}\n\n"

    f.puts "\\pagebreak"
  end

  f.puts <<EOS

\\end{document}
EOS

end
