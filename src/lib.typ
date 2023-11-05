#let code(
  line-spacing: 5pt,
  line-offset: 5pt,
  numbering: true,
  inset: 5pt,
  radius: 3pt,
  stroke: 1pt + luma(180),
  fill: luma(250),
  text-style: (),
  width: auto,
  lines: auto,
  lang-box: (
    radius: 3pt,
    outset: 2pt,
    fill: rgb("#ffbfbf"),
    stroke: 1pt + rgb("#ff8a8a")
  ),
  lang: none,
  source
) = {
  show raw.line: set text(..text-style)
  show raw: set text(..text-style)
  
  set par(justify: false, leading: line-spacing)

  let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")
  
  let number-styling(number) = text(
    fill: stroke.paint,
    size: 1.25em, // TODO: Fix this when Typst 0.9.1/0.10.0 come out
    raw(str(number))
  )

  let labels = source
    .text
    .split("\n")
    .map(line => {
      let match = line.match(label-regex)
  
      if match != none {
        match.captures.at(0)
      } else {
        none
      }
    })

  let unlabelled-source = source.text.replace(
    label-regex,
    "\n"
  )
  
  show raw.where(block: true): it => {
    style(styles => {
      let max-number-size = measure(
        number-styling(it.lines.at(-1).number),
        styles
      ).width

      let lines = if lines == auto {
        (0, it.lines.len())
      } else {
        (lines.at(0) - 1, lines.at(1))
      }

      block(
        inset: inset,
        radius: radius,
        stroke: stroke,
        fill: fill,
        width: width,
        { 
          table(
            columns: (if numbering { max-number-size + line-offset } else { auto }, auto, 1fr),
            inset: 0pt,
            stroke: none,
            row-gutter: line-spacing,
            ..it
              .lines
              .slice(..lines)
              .map(line => (
                if numbering {
                  number-styling(line.number)
                } else {
                  none
                },
                {
                  let line-label = labels.at(line.number - 1)
                  
                  if line-label != none {
                    show figure: it => it.body
                    
                    counter(figure.where(kind: "sourcerer")).update(line.number - 1)
                    [
                      #figure(supplement: "Line", kind: "sourcerer", outlined: false, line)
                      #label(line-label)
                    ]
                  } else {
                    line
                  }
                },
                if line.number - 1 == lines.at(0) {
                  place(
                    right + top,
                    rect(
                      fill: lang-box.fill,
                      stroke: lang-box.stroke,
                      inset: 0pt,
                      outset: lang-box.outset,
                      radius: radius,
                      raw(lang)
                    )
                  )
                } else {
                  none
                }
              ))
              .sum()
          )
        }
      )
    })
  }

  raw(block: true, lang: source.lang, unlabelled-source)
}
