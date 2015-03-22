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
  f4 g ( a) a\breve b4 a \parenthesize a g a \bar "|" a a a a g f g ( a ) g4. \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 2.} K os-} la- 
\once \override LyricText.self-alignment-X = #LEFT
"vě utrpení" na- še- ho- Pá- na \markup{{\with-color #red ℟.}Da-} ry ty- to při- ná- ší- me.
  }
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 3.} Ve} ví- 
\once \override LyricText.self-alignment-X = #LEFT
"ře ve výkupnou" o- běť _ Kří- že \markup{{\with-color #red ℟.}Da-} ry ty- to při- ná- ší- me.
  }
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 4.} V na-} dě- 
\once \override LyricText.self-alignment-X = #LEFT
"ji ve" věč- nou _ spá- su \markup{{\with-color #red ℟.}Da-} ry ty- to při- ná- ší- me.
  }
  >>
}
\header {
  tagline = ""
}
