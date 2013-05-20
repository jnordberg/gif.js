require 'browsernizr/test/css/rgba'
require 'browsernizr/test/css/transforms3d'
Modernizr = require 'browsernizr'

require './vendor/mootools.js'

async = require 'async'
ready = require './vendor/ready.js'

now = window.performance?.now?.bind(window.performance) or Date.now

loadImage = (src, callback) ->
  img = new Image()
  img.onload = ->
    callback null, img
  img.onerror = ->
    callback new Error "Could load #{ src }"
  img.src = src

setupDemo = (element) ->
  element.getElements('.hover-buttons li').addEvents
    mouseenter: -> element.addClass @className
    mouseleave: -> element.removeClass @className

  qslider = element.getElement '.quality input'
  qvalue = element.getElement '.quality span'
  renderimg = element.getElement 'img.render'
  logel = element.getElement 'pre'

  gif = new GIF
    quality: 10
    workers: 2

  startTime = null
  gif.on 'start', ->
    startTime = now()

  gif.on 'finished', (blob) ->
    renderimg.src = URL.createObjectURL(blob)
    delta = now() - startTime
    logel.set 'text', "Rendered #{ images.length } frame(s) at q#{ gif.options.quality } in #{ delta.toFixed(2) }ms"

  gif.on 'progress', (p) ->
    logel.set 'text', "Rendering #{ images.length } frame(s) at q#{ gif.options.quality }... #{ Math.round(p * 100) }%"

  images = element.getElements('img.original').map (img) -> img.src
  async.map images, loadImage, (error, images) ->
    throw error if error?
    gif.addImage image, 500 for image in images
    gif.render()

  qslider.addEvent 'change', ->
    val = 31 - parseInt qslider.value
    qvalue.set 'text', val
    gif.setOption 'quality', val
    gif.abort()
    gif.render()

  delay = element.getElement '.delay'
  if delay?
    delay.getElement('input').addEvent 'change', ->
      value = parseInt this.value
      delay.getElement('.value').set 'text', value + 'ms'
      for image in gif.images
        image.delay = value
      gif.abort()
      gif.render()

  repeat = element.getElement '.repeat'
  if repeat?
    repeat.getElement('input').addEvent 'change', ->
      value = parseInt this.value
      value = -1 if value is 0
      value = 0 if value is 21
      switch value
        when 0
          txt = 'forever'
        when -1
          txt = 'none'
        else
          txt = value
      repeat.getElement('.value').set 'text', txt
      gif.setOption 'repeat', value
      gif.abort()
      gif.render()

ready ->
  for demo in document.body.querySelectorAll '.demo'
    setupDemo demo
