# read stdin, write to stdout without gregorio music (i.e. anything in brackets)

while l = gets do
  puts l.gsub(/\([^\(\)]*\)/, '')
end
