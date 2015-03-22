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
  }
}

\score {
  <<
  \new Staff {
    \new Voice = "one" { \relative c' {
  \key c \major
  \time 4/4
  \partial 4
  e8 f | g a g f e4 e8 f | g a g [( f )] e4 e8 e | a4 f8 [( e )] d4 d8 e | f g a [( h )] e,4 e \bar "|."
}
}
}
    \new Lyrics \lyricsto "one" {
      Ot- če ne- mů- že- li mne ten- to ka- lich mi- nout, a- niž bych jej pil, ať se sta- ne tvá vů- le.
  }
  >>
}
\header {
  tagline = ""
}
