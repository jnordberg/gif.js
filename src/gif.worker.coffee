GIFEncoder = require './GIFEncoder.js'

renderFrame = (frame) ->
  encoder = new GIFEncoder frame.globalOptions.width, frame.globalOptions.height

  if frame.index is 0
    encoder.writeHeader()
  else
    encoder.firstFrame = false

  encoder.setTransparent frame.transparent
  encoder.setDispose frame.dispose
  encoder.setRepeat frame.repeat
  encoder.setDelay frame.delay
  encoder.setQuality frame.quality
  encoder.setDither frame.dither
  encoder.setGlobalPalette frame.globalPalette
  frameOptions = Object.assign({}, frame, { data: null })
  encoder.setPosition frame.left, frame.top
  encoder.addFrame frame.data, frameOptions
  encoder.finish() if frame.last
  if frame.globalPalette == true
    frame.globalPalette = encoder.getGlobalPalette()

  stream = encoder.stream()
  frame.data = stream.pages
  frame.cursor = stream.cursor
  frame.pageSize = stream.constructor.pageSize

  if frame.canTransfer
    # frame.data 是个数组，数组元素是 Uint8Array 对象，Uint8Array 对象有buffer属性。
    transfer = (page.buffer for page in frame.data)
    self.postMessage frame, transfer
  else
    self.postMessage frame

self.onmessage = (event) -> renderFrame event.data
