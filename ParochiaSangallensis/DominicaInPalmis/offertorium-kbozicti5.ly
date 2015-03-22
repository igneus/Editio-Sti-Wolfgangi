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
  a'4 a b a g a \bar "|" a a a a g f g ( a ) g4. \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 5.} V lás-} ce k_Bo- ží cír- kvi \markup{{\with-color #red ℟.}Da-} ry ty- to při- ná- ší- me.
  }
  >>
}
\header {
  tagline = ""
}
