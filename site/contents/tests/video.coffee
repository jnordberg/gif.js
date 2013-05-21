require '../scripts/vendor/mootools.js'
ready = require '../scripts/vendor/ready.js'
now = window.performance?.now?.bind(window.performance) or Date.now

ready ->
  info = document.id 'info'
  video = document.id 'video'
  button = document.id 'go'
  sample = document.id 'sample'

  gif = new GIF
    workers: 4
    workerScript: '/gif.js/gif.worker.js'
    width: 600
    height: 337

  startTime = null
  sampleInterval = null

  sampleUpdate = ->
    sampleInterval = parseInt sample.value
    gif.abort()
    document.id('info').set 'text', """
      ready to start with a sample interval of #{ sampleInterval }ms
    """

  video.addEventListener 'canplay', ->
    button.disabled = false
    sample.disabled = false
    sampleUpdate()

  sample.addEvent 'change', sampleUpdate

  button.addEvent 'click', ->
    video.pause()
    video.currentTime = 0
    gif.abort()
    gif.frames = []
    video.play()

  gif.on 'start', -> startTime = now()

  gif.on 'progress', (p) ->
    info.set 'text', "rendering: #{ Math.round(p * 100) }%"

  gif.on 'finished', (blob) ->
    img = document.id 'result'
    img.src = URL.createObjectURL(blob)
    delta = now() - startTime
    info.set 'text', """
      done in
      #{ (delta / 1000).toFixed 2 }sec,
      size #{ (blob.size / 1000).toFixed 2 }kb
    """

  # this might not be the best approach to capturing
  # html video, but i but i can't seek since my dev server
  # doesn't support http byte requests
  timer = null
  capture = ->
    info.set 'html', "capturing at #{ video.currentTime }"
    gif.addFrame video, {copy: true, delay: sampleInterval}

  video.addEventListener 'play', ->
    clearInterval timer
    timer = setInterval capture, sampleInterval

  video.addEventListener 'ended', ->
    clearInterval timer
    gif.render()
