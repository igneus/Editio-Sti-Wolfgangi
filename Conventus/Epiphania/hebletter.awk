#!/bin/awk -f
function romtonum(txt,   rom, num)
{
  rom=gensub(/^.*\/ps118([ivx]*)_.*$/,"\\1","",txt);
  num=0;
  while (length(rom)>0) {
    if (substr(rom,1,2) == "iv") {num+=4;rom=substr(rom,3)}
    else if (substr(rom,1,2) == "ix") {num+=9;rom=substr(rom,3)}
    else if (substr(rom,1,1) == "i") {num+=1;rom=substr(rom,2)}
    else if (substr(rom,1,1) == "v") {num+=5;rom=substr(rom,2)}
    else if (substr(rom,1,1) == "x") {num+=10;rom=substr(rom,2)}
  }
  return num
}
function romtoheb(txt, adj,   num)
{
  num=romtonum(txt)+adj
  return substr("אבגדהוזחטיכלמנסעפצקרשת",num,1)
}
BEGIN{ if (TEX == 0){printf romtoheb(PSLM,0);exit 0} if (TEX == 2){nspc=7;adj=-1}else{nspc=1;adj=0} }
/^$/ {nspc=nspc+1;print;next}
/^Gló.*ri.*a.*Pat.*ri.*et.*Fí.*li.*o/ {if (nspc==8){nspc=0}}
{ if (nspc==8){adj=adj+1;nspc=0;printf "\\hebinitial{%s}", romtoheb(PSLM,adj)}; print}
