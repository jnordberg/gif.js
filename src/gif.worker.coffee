GIFEncoder = require './GIFEncoder.js'

renderFrame = (frame) ->
  encoder = new GIFEncoder frame.width, frame.height

  if frame.index is 0
    encoder.writeHeader()
  else
    encoder.firstFrame = false

  encoder.setTransparent frame.transparent
  encoder.setRepeat frame.repeat
  encoder.setDelay frame.delay
  encoder.setQuality frame.quality
  encoder.setDither frame.dither
  encoder.setGlobalPalette frame.globalPalette
  encoder.addFrame frame.data
  encoder.finish() if frame.last
  if frame.globalPalette == true
    frame.globalPalette = encoder.getGlobalPalette()

  stream = encoder.stream()
  frame.data = stream.pages
  frame.cursor = stream.cursor
  frame.pageSize = stream.constructor.pageSize

  if frame.canTransfer
    transfer = (page.buffer for page in frame.data)
    self.postMessage frame, transfer
  else
    self.postMessage frame

self.onmessage = (event) -> renderFrame event.data
