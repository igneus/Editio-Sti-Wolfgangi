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
  e8 e h'4 a8 g fis4 \breathe a8 a g [ fis ] g fis e \bar "|."
}
}
}
    \new Lyrics \lyricsto "one" {
      Bo- že můj, Bo- že můj, proč jsi mě _ o- pus- til?
  }
  >>
}
\header {
  tagline = ""
}
