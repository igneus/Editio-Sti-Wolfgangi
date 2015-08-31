#!/bin/awk -f
function trLine()
{
  ret=""
  while ((getline trline < TRFILE) > 0)
    {
      if (trline ~ /\\(begin|end){psalmus}/)
	continue
      if (trline ~ /^[[:space:]]*$/) {
	if (ret == "")
	  continue
	else
	  break
      }
      if (ret == "")
	ret = trline
      else
	ret = ret " " trline
    }
  return "& \\psalmusTr{" ret "} \\\\"
}
function printLine(tail)
{
  if (line) { print line " " trLine() tail } line = ""
}
BEGIN {
  while (PSSKIP > 0) {
    print trLine()
    PSSKIP = PSSKIP - 1
  }
  
}
/\\(begin|end){psalmus}/ {next}
/\\nadpisZalmu/ {next}
(NF == 0) { printLine(""); next }
/^\\\\$/ { printLine("[0.5cm]"); print "\\"; next }
{ if (line == "") { line = $0 } else { line = line " " $0 } }
END { printLine("") }
