require '../scripts/vendor/mootools.js'
ready = require '../scripts/vendor/ready.js'

num_frames = 20
width = 600
height = 300
text = 'HYPNO TOAD'
textSize = 70

now = window.performance?.now?.bind(window.performance) or Date.now

rgb = (rgb...) -> "rgb(#{ rgb.map((v) -> Math.floor(v * 255)).join(',') })"
hsl = (hsl...) ->
  hsl = hsl.map (v, i) -> if i is 0 then v * 360 else "#{ v * 100 }%"
  return "hsl(#{ hsl.join(',') })"

ready ->
  canvas = document.createElement 'canvas'
  canvas.width = width
  canvas.height = height

  startTime = null
  ctx = canvas.getContext '2d'
  info = document.id 'info'

  gif = new GIF
    workers: 4
    workerScript: '/gif.js/gif.worker.js'
    width: width
    height: height

  gif.on 'start', -> startTime = now()

  gif.on 'progress', (p) -> info.set 'text', Math.round(p * 100)+'%'

  gif.on 'finished', (blob) ->
    img = document.id 'result'
    img.src = URL.createObjectURL(blob)
    delta = now() - startTime
    info.set 'text', """
      100%
      #{ (delta / 1000).toFixed 2 }sec
      #{ (blob.size / 1000).toFixed 2 }kb
    """

  ctx.font = "bold #{ textSize }px Helvetica"
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.lineWidth = 3
  w2 = width / 2
  h2 = height / 2
  for i in [0...num_frames]
    p = i / (num_frames - 1)
    grad = ctx.createRadialGradient w2, h2, 0, w2, h2, w2
    grad.addColorStop 0, hsl p, 1, 0.5
    grad.addColorStop 1, hsl (p + 0.2) % 1, 1, 0.4
    ctx.fillStyle = grad
    ctx.fillRect 0, 0, width, height
    ctx.fillStyle = hsl (p + 0.5) % 1, 1, 0.7
    ctx.strokeStyle = hsl (p + 0.8) % 1, 1, 0.9
    ctx.fillText text, w2, h2
    ctx.strokeText text, w2, h2
    gif.addFrame ctx, {copy: true, delay: 20}

  gif.render()
