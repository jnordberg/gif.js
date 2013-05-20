{EventEmitter} = require 'events'

class GIF extends EventEmitter

  defaults =
    workerScript: 'gif.worker.js'
    workers: 2
    repeat: 0 # repeat forever, -1 = repeat once
    background: '#fff'
    quality: 10 # pixel sample interval, lower is better

  constructor: (@options={}) ->
    @running = false
    @images = []
    @freeWorkers = []
    @activeWorkers = []
    @canvas = document.createElement 'canvas'
    for key, value of defaults
      @options[key] ?= value

  setOption: (key, value) ->
    @options[key] = value

  setOptions: (options) ->
    for key, value of options
      @options[key] = value

  addImage: (image, delay=1000, origin=[0, 0]) ->
    @images.push {image, delay, origin}
    if not @size?
      @setSize [image.width, image.height]

  setSize: (@size) ->
    @canvas.width = @size[0]
    @canvas.height = @size[1]

  render: ->
    throw new Error 'Already running' if @running

    @running = true
    @nextFrame = 0
    @finishedFrames = 0

    @imageParts = (null for i in [0...@images.length])
    numWorkers = @spawnWorkers()
    @renderNextFrame() for i in [0...numWorkers]

    @emit 'start'
    @emit 'progress', 0

  abort: ->
    loop
      worker = @activeWorkers.shift()
      break unless worker?
      console.log "killing active worker"
      worker.terminate()
    @running = false
    @emit 'abort'

  # private

  spawnWorkers: ->
    numWorkers = Math.min(@options.workers, @images.length)
    for i in [@freeWorkers.length...numWorkers]
      console.log "spawning worker"
      worker = new Worker @options.workerScript
      worker.onmessage = (event) =>
        @activeWorkers.splice @activeWorkers.indexOf(worker), 1
        @freeWorkers.push worker
        @frameFinished event.data
      @freeWorkers.push worker
    return numWorkers

  frameFinished: (frame) ->
    console.log "frame #{ frame.index } finished"
    @finishedFrames++
    @emit 'progress', @finishedFrames / @images.length
    @imageParts[frame.index] = frame
    if null in @imageParts
      @renderNextFrame()
    else
      @finishRendering()

  finishRendering: ->
    len = 0
    for frame in @imageParts
      len += (frame.data.length - 1) * frame.pageSize + frame.cursor
    len += frame.pageSize - frame.cursor
    console.log "rendering finished - filesize #{ Math.round(len / 1000) }kb"
    data = new Uint8Array len
    offset = 0
    for frame in @imageParts
      for page, i in frame.data
        data.set page, offset
        if i is frame.data.length - 1
          offset += frame.cursor
        else
          offset += frame.pageSize

    image = new Blob [data],
      type: 'image/gif'

    @emit 'finished', image, data

  renderNextFrame: ->
    if @freeWorkers.length is 0
      throw new Error 'Can not start next frame, no free workers!'
    return if @nextFrame >= @images.length # no new frame to render
    image = @images[@nextFrame++]
    worker = @freeWorkers.shift()
    frame = @getFrame image
    console.log "starting frame #{ frame.index + 1 } of #{ @images.length }"
    @activeWorkers.push worker
    worker.postMessage frame

  getFrame: (image) ->
    index = @images.indexOf image
    frame =
      delay: image.delay
      width: @size[0]
      height: @size[1]
      index: index
      quality: @options.quality
      repeat: @options.repeat
      last: index is (@images.length - 1)
    ctx = @canvas.getContext '2d'
    ctx.setFill = @options.background
    ctx.fillRect 0, 0, @size[0], @size[1]
    ctx.drawImage image.image, image.origin[0], image.origin[1]
    frame.data = ctx.getImageData(0, 0, @size[0], @size[1]).data
    return frame

module.exports = GIF
