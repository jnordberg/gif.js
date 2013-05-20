{NeuQuant} = require './TypedNeuQuant.js'

###
typed 100 runs:
  run finished at q1
  avg: 661.46ms median: 660.54ms
  run finished at q10
  avg: 67.49ms median: 67.03ms
  run finished at q20
  avg: 34.56ms median: 34.19ms
normal 100 runs:
  run finished at q1
  avg: 888.10ms median: 887.63ms
  run finished at q10
  avg: 92.85ms median: 91.99ms
  run finished at q20
  avg: 46.14ms median: 45.68ms
###

quality = 10 # pixel sample interval, 1 being the best quality
runs = 100

if window.performance?.now?
  now = -> window.performance.now()
else
  now = Date.now

window.addEventListener 'load', ->
  img = document.getElementById 'image'
  canvas = document.getElementById 'canvas'

  w = canvas.width = img.width
  h = canvas.height = img.height

  ctx = canvas.getContext('2d')
  ctx.drawImage(img, 0, 0)

  imdata = ctx.getImageData(0, 0, img.width, img.height)
  rgba = imdata.data

  rgb = new Uint8Array w * h * 3
  #rgb = new Array w * h * 3

  rgb_idx = 0
  for i in [0...rgba.length] by 4
    rgb[rgb_idx++] = rgba[i + 0]
    rgb[rgb_idx++] = rgba[i + 1]
    rgb[rgb_idx++] = rgba[i + 2]

  runtimes = []
  for run in [0...runs]
    start = now()
    imgq = new NeuQuant rgb, quality
    imgq.buildColormap()
    end = now()
    delta = end - start
    runtimes.push delta

  console.log runtimes.join('\n')

  map = imgq.getColormap()
  avg = runtimes.reduce((p, n) -> p + n) / runtimes.length
  median = runtimes.sort()[Math.floor(runs / 2)]
  console.log """
    run finished at q#{ quality }
    avg: #{ avg.toFixed(2) }ms median: #{ median.toFixed(2) }ms
  """

  for y in [0...h]
    for x in [0...w]
      idx = (y * w + x) * 4

      r = rgba[idx + 0]
      g = rgba[idx + 1]
      b = rgba[idx + 2]

      map_idx = imgq.lookupRGB(r, g, b) * 3

      rgba[idx + 0] = map[map_idx]
      rgba[idx + 1] = map[map_idx + 1]
      rgba[idx + 2] = map[map_idx + 2]

  ctx.putImageData imdata, 0, 0

  for i in [0...map.length] by 3
    color = [map[i], map[i + 1], map[i + 2]]
    el = document.createElement 'span'
    el.style.display = 'inline-block'
    el.style.height = '1em'
    el.style.width = '1em'
    el.style.background = 'rgb(' + color.join(',') + ')'
    document.body.appendChild el
