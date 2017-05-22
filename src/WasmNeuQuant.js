var fs = require('fs')

// this is an ugly hack since i don't want to
// refactor the worker for async loads just yet
var src = fs.readFileSync(__dirname + '/NeuQuant.wasm')
var wamodule = new WebAssembly.Module(src)
var instance
var memarray

function NeuQuant(pixels, samplefac) {
  if (!instance) {
    var table = new WebAssembly.Table({initial: 0, element: 'anyfunc'})
    var memory = new WebAssembly.Memory({initial: 1})
    memarray = new Uint8Array(memory.buffer)

    var env = {}
    env.memoryBase = 0
    env.memory = memory
    env.tableBase = 0
    env.table = table

    env.memset = function(){} // instance complains about it missing
                              // when compiled with optimizations,
                              // seems not to have any effect?

    env._grow = function() { memarray = new Uint8Array(memory.buffer) }
    env._abort = function() { throw new Error('Abort') }
    env._exit = function() { throw new Error('Exit') }
    instance = new WebAssembly.Instance(wamodule, {env: env})
  }

  var pixelPtr = instance.exports.malloc(pixels.byteLength)
  memarray.set(pixels, pixelPtr)

  instance.exports.init(pixelPtr, pixels.length, samplefac)

  this.buildColormap = function(){
    instance.exports.learn()
    instance.exports.unbiasnet()
    instance.exports.inxbuild()
    instance.exports.free(pixelPtr)
  }

  this.getColormap = function(){
    var map = new Uint8Array(256*3)
    var mapPtr = instance.exports.getColormap()
    map.set(memarray.subarray(mapPtr, mapPtr + map.byteLength))
    return map
  }

  this.lookupRGB = instance.exports.inxsearch
}

module.exports = NeuQuant
