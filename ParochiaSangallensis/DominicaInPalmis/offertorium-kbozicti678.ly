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
  f4 g ( a) a\breve b4 a g a \bar "|" a a a a a g f g ( a ) g4. \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 6.} Je-} di- 
\once \override LyricText.self-alignment-X = #LEFT
"nému Bohu v nepří-" stup- ném svět- le: \markup{{\with-color #red ℟.}čest} a slá- va na vě- ky. A- men.
  }
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 7.} Je-} ží-
\once \override LyricText.self-alignment-X = #LEFT
"ši Kristu," Krá- li slá- vy: \markup{{\with-color #red ℟.}čest} a slá- va na vě- ky. A- men.
  }
    \new Lyrics \lyricsto "one" {
\markup{{\with-color #red \italic 8.} Du-} chu
\once \override LyricText.self-alignment-X = #LEFT
"svatému, prameni a" stráž- ci prav- dy: \markup{{\with-color #red ℟.}čest} a slá- va na vě- ky. A- men.
  }
  >>
}
\header {
  tagline = ""
}
