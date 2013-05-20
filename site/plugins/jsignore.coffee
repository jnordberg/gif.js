module.exports = (env, callback) ->
  # hack to have browserify ignore the symlinked gif.js
  env.registerContentPlugin 'files', 'gif.*js', env.plugins.StaticFile
  callback()
