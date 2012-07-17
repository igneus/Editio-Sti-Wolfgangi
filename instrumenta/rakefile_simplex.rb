def gregorio(srcf)
  f2 = srcf.gsub(".gabc", ".tex")
  file f2 => [srcf] do
    sh "gregorio #{srcf}"
  end
  return f2
end

def cantus_hic
  cantus = []

  Dir["./cantus/*.gabc"].each {|t|
    cantus << gregorio(t)
  }
  return cantus
end

def texfile_cum_cantibus(texfile)
  pdffile = texfile.gsub /\.tex$/, '.pdf'
  cantus = cantus_hic

  file pdffile => [texfile]+cantus do |t|
    sh "lualatex -interaction=nonstopmode "+t.prerequisites.first
  end

  return pdffile
end

