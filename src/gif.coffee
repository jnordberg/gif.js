{EventEmitter} = require 'events'
browser = require './browser.coffee'

class GIF extends EventEmitter

  defaults =
    workerScript: 'gif.worker.js'
    workers: 2
    repeat: 0 # repeat forever, -1 = repeat once
    background: '#fff'
    quality: 10 # pixel sample interval, lower is better
    width: null # size derermined from first frame if possible
    height: null
    transparent: null
    debug: false
    dither: false # see GIFEncoder.js for dithering options

  frameDefaults =
    delay: 500 # ms
    copy: false
    dispose: -1

  constructor: (options) ->
    @running = false

    @options = {}
    @frames = []

    @freeWorkers = []
    @activeWorkers = []

    @setOptions options
    for key, value of defaults
      @options[key] ?= value

  setOption: (key, value) ->
    @options[key] = value
    if @_canvas? and key in ['width', 'height']
      @_canvas[key] = value

  setOptions: (options) ->
    @setOption key, value for own key, value of options

  addFrame: (image, options={}) ->
    frame = {}
    frame.transparent = @options.transparent
    for key of frameDefaults
      frame[key] = options[key] or frameDefaults[key]

    # use the images width and height for options unless already set
    @setOption 'width', image.width unless @options.width?
    @setOption 'height', image.height unless @options.height?

    if ImageData? and image instanceof ImageData
       frame.data = image.data
    else if (CanvasRenderingContext2D? and image instanceof CanvasRenderingContext2D) or (WebGLRenderingContext? and image instanceof WebGLRenderingContext)
      if options.copy
        frame.data = @getContextData image
      else
        frame.context = image
    else if image.childNodes?
      if options.copy
        frame.data = @getImageData image
      else
        frame.image = image
    else
      throw new Error 'Invalid image'

    @frames.push frame

  render: ->
    throw new Error 'Already running' if @running

    if not @options.width? or not @options.height?
      throw new Error 'Width and height must be set prior to rendering'

    @running = true
    @nextFrame = 0
    @finishedFrames = 0

    @imageParts = (null for i in [0...@frames.length])
    numWorkers = @spawnWorkers()
    # we need to wait for the palette
    if @options.globalPalette == true
      @renderNextFrame()
    else
      @renderNextFrame() for i in [0...numWorkers]

    @emit 'start'
    @emit 'progress', 0

  abort: ->
    loop
      worker = @activeWorkers.shift()
      break unless worker?
      @log 'killing active worker'
      worker.terminate()
    @running = false
    @emit 'abort'

  # private

  spawnWorkers: ->
    numWorkers = Math.min(@options.workers, @frames.length)
    [@freeWorkers.length...numWorkers].forEach (i) =>
      @log "spawning worker #{ i }"
      worker = new Worker @options.workerScript
      worker.onmessage = (event) =>
        @activeWorkers.splice @activeWorkers.indexOf(worker), 1
        @freeWorkers.push worker
        @frameFinished event.data
      @freeWorkers.push worker
    return numWorkers

  frameFinished: (frame) ->
    @log "frame #{ frame.index } finished - #{ @activeWorkers.length } active"
    @finishedFrames++
    @emit 'progress', @finishedFrames / @frames.length
    @imageParts[frame.index] = frame
    # remember calculated palette, spawn the rest of the workers
    if @options.globalPalette == true
      @options.globalPalette = frame.globalPalette
      @log 'global palette analyzed'
      @renderNextFrame() for i in [1...@freeWorkers.length] if @frames.length > 2
    if null in @imageParts
      @renderNextFrame()
    else
      @finishRendering()

  finishRendering: ->
    len = 0
    for frame in @imageParts
      len += (frame.data.length - 1) * frame.pageSize + frame.cursor
    len += frame.pageSize - frame.cursor
    @log "rendering finished - filesize #{ Math.round(len / 1000) }kb"
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
    throw new Error 'No free workers' if @freeWorkers.length is 0
    return if @nextFrame >= @frames.length # no new frame to render

    frame = @frames[@nextFrame++]
    worker = @freeWorkers.shift()
    task = @getTask frame

    @log "starting frame #{ task.index + 1 } of #{ @frames.length }"
    @activeWorkers.push worker
    worker.postMessage task#, [task.data.buffer]

  getContextData: (ctx) ->
    return ctx.getImageData(0, 0, @options.width, @options.height).data

  getImageData: (image) ->
    if not @_canvas?
      @_canvas = document.createElement 'canvas'
      @_canvas.width = @options.width
      @_canvas.height = @options.height

    ctx = @_canvas.getContext '2d'
    ctx.clearRect 0, 0, @options.width, @options.height
    ctx.fillStyle = @options.background
    ctx.fillRect 0, 0, @options.width, @options.height
    if image instanceof ImageData
      ctx.putImageData image, 0, 0
      return image
    ctx.drawImage image, 0, 0
    return @getContextData ctx

  getBgImageData:  -> 
    bg_canvas = document.createElement 'canvas'
    bg_canvas.width = @options.width
    bg_canvas.height = @options.height
    bg_ctx = bg_canvas.getContext '2d'
    bg_ctx.fillStyle = '#ffffff';
    bg_ctx.fillRect 0, 0, @options.width, @options.height
    bg_ctx.drawImage @_canvas, 0, 0
    return @getContextData bg_ctx
  
  getTask: (frame) ->
    index = @frames.indexOf frame
    task =
      index: index
      last: index is (@frames.length - 1)
      delay: frame.delay
      dispose: frame.dispose
      transparent: frame.transparent
      width: @options.width
      height: @options.height
      quality: @options.quality
      dither: @options.dither
      globalPalette: @options.globalPalette
      repeat: @options.repeat
      canTransfer: (browser.name is 'chrome')

    if frame.data?
      task.data = frame.data
      task.data = @getContextData frame.data
      task.bg_data = @getBgImageData()
    else if frame.context?
      task.data = @getContextData frame.context
      task.bg_data = @getBgImageData()
    else if frame.image?
      task.data = @getImageData frame.image
      task.bg_data = @getBgImageData()
    else
      throw new Error 'Invalid frame'

    return task

  log: (args...) ->
    return unless @options.debug
    console.log args...


module.exports = GIF
