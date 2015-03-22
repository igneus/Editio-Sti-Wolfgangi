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
  line-width = #180
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
  f4 g ( a) b a g a \bar "|" a a a a g f g ( a ) g4. \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 1.} K Bo-} ží cti a slá- vě \markup{{\with-color #red ℟.}Da-} ry ty- to při- ná- ší- me.
  }
  >>
}
\header {
  tagline = ""
}
