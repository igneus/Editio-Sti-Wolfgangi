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
  \key g \major
  \cadenzaOn
  h'\breve g8 a \once \override Stem.direction = #UP \parenthesize h h4 \bar "|" a\breve \slurDotted g8 ( fis ) e4 \bar "||"
}
}
}
    \new Lyrics \lyricsto "one" {
      \markup { { \with-color #red \italic 1. } "Posmívají se mi všichni,         " } \markup { \bold kdo } mě vi- dí,
      \once \override LyricText.self-alignment-X = #LEFT
      "šklebí rty, pokyvují        " \markup { \bold hla- } vou.
  }
  >>
}
\header {
  tagline = ""
}
