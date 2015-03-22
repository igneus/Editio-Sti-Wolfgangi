\version "2.11.57"
\include "deutsch.ly"

\paper {
  indent = #0
  #(define fonts
    (make-pango-font-tree "Junicode"
                          "Nimbus Sans"
                          "Luxi Mono"
                          (/ staff-height pt 20)))
}

\layout {
  line-width = #150
  \context {
    \Score
    \omit BarNumber
    \omit TimeSignature
  }
}

\score {
  <<
  \new Staff {
    \new Voice = "one" { \relative c' {
  \key f \major
  \cadenzaOn
  a'\breve b8 a4 \breathe a8 a g f e f4 d \bar "|"
  a'\breve d8 d a4 a8 b a g [ f g ] a4 \breathe a8 a a b a g f e [ f ] d4 \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
      "Kristus se pro nás stal poslušný až" k_smr- ti a to k_smr- ti na kří- ži.
      "Proto také ho Bůh" po- vý- šil a dal mu jmé- _ _ no, kte- ré je na- de všech- no jmé- _ no.
  }
  >>
}
\header {
  tagline = ""
}
