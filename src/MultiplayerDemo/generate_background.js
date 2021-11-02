const BLACK = '#111'
const WHITE = '#FCFCFC'
const PURPLE = 'rgb(165, 24, 201)'
const PINK = '#E62EA5'

const WIDTH = 69
const HEIGHT = WIDTH

const OUTLINE_WIDTH = 1

const DOT_SIZE = WIDTH / 12

console.log(`
<svg version="1.1" baseProfile="full" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewbox="0 0 ${WIDTH} ${HEIGHT}" width="${WIDTH}" height="${HEIGHT}">
  <style>
    .dot {
      fill: ${PURPLE};
      stroke: ${WHITE};
      stroke-width: ${OUTLINE_WIDTH};
    }
    .bg {
      fill: ${BLACK};
    }
  </style>
  <rect class="bg" width="${WIDTH}" height="${HEIGHT}" />
<g transform="rotate(-90, ${WIDTH/2} ${HEIGHT/2}) translate(${WIDTH/2}, ${HEIGHT/2})">
  <!--${makeDots(6, WIDTH / 6)}-->

  <!--${makeDots(6, (WIDTH / 6) * 2, 30)}-->

  ${makeDots(6, (WIDTH / 6) * 2 + DOT_SIZE / 2)}

  <circle class="dot" r="${DOT_SIZE}"/>
</g>
</svg>
`)

function makeDots (n, scale, offset = 0, size = DOT_SIZE) {
  return makeCorners(n, offset).map((theta) => {
    return `<circle class="dot" r="${size}" ${centerPoint(theta, scale)} />`
  }).join('\n')
}

function makeCorners (n, offset = 0) {
  const increment = 360 / n
  const corners = []
  for (let i = 0; i < n; i++) {
    corners.push(i * increment + offset)
  }

  return corners
}

function centerPoint (theta, scale = 1) {
  return `cx="${xAt(theta) * scale}" cy="${yAt(theta) * scale}"`
}

function xAt (theta) {
  return Math.cos(toRad(theta))
}

function yAt (theta) {
  return Math.sin(toRad(theta))
}

function toRad (theta) {
  return Math.PI / 180 * theta
}
