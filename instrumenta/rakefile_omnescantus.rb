# include this in the rakefile to create overview of chants in the given
# directory using script omnescantus.rb .

# Prior to including:
# * define variable 'path_to_instrumenta'

# makes one document with all the chants from this directory

script = $path_to_instrumenta + '/omnescantus.rb'

chants = Dir['*.gabc']
compiledchants = chants.map do |c|
  cc = c.gsub(/\.gabc$/, '.tex')
  file cc => [c] do |t|
    sh "gregorio #{c}"
  end
  cc # return value
end

file 'omnescantus.tex' => chants+[script] do |t|
  sh "ruby #{script} #{Dir.pwd} #{t.name}"
end

file 'omnescantus.pdf' => ['omnescantus.tex']+compiledchants do |t|
  sh "lualatex -interaction=nonstopmode "+t.prerequisites[0]
end

task :chantsoverview => ['omnescantus.pdf']
