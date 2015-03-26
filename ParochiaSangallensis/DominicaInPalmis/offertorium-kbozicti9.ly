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
    \new Voice = "five" { \relative c' {
  \key f \major
  \cadenzaOn
  f4 g ( a) a\breve b4 a g a \bar "|" g f4. \bar "||"
}
}
}
    \new Lyrics \lyricsto "five" {
\once \override LyricText.self-alignment-X = #0.4
\markup{{\with-color #red \italic 9.} Lá-} ska 
\once \override LyricText.self-alignment-X = #LEFT
"Boha trojjediného přebývej" v_na- šich srd- cích. \markup{{\with-color #red ℟.}A-} men.
  }
  >>
}
\header {
  tagline = ""
}
