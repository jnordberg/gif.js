GIFEncoder = require './GIFEncoder.js'

renderFrame = (frame) ->
  encoder = new GIFEncoder frame.width, frame.height

  if frame.index is 0
    encoder.writeHeader()
  else
    encoder.firstFrame = false

  encoder.setRepeat frame.repeat
  encoder.setDelay frame.delay
  encoder.setQuality frame.quality
  encoder.addFrame frame.data
  encoder.finish() if frame.last

  stream = encoder.stream()
  frame.data = stream.pages
  frame.cursor = stream.cursor
  frame.pageSize = stream.constructor.pageSize

  transfer = (page.buffer for page in frame.data)
  self.postMessage frame, transfer

self.onmessage = (event) -> renderFrame event.data
