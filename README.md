
# gif.js

JavaScript GIF encoder that runs in your browser.

Uses typed arrays and web workers to render each frame in the background, it's really fast!

**Demo** - http://jnordberg.github.io/gif.js/

Works in browsers supporting: [Web Workers](http://www.w3.org/TR/workers/), [File API](http://www.w3.org/TR/FileAPI/) and [Typed Arrays](https://www.khronos.org/registry/typedarray/specs/latest/)


## Usage

Include `gif.js` found in `dist/` in your page. Also make sure to have `gif.worker.js` in the same location.

```javascript
var gif = new GIF({
  workers: 2,
  quality: 10
});

// add an image element
gif.addFrame(imageElement);

// or a canvas element
gif.addFrame(canvasElement, {delay: 200});

// or copy the pixels from a canvas context
gif.addFrame(ctx, {copy: true});

gif.on('finished', function(blob) {
  window.open(URL.createObjectURL(blob));
});

gif.render();

```

## Options

Options can be passed to the constructor or using the `setOptions` method.

| Name         | Default         | Description                                        |
| -------------|-----------------|----------------------------------------------------|
| repeat       | `0`             | repeat count, `-1` = no repeat, `0` = forever      |
| quality      | `10`            | pixel sample interval, lower is better             |
| workers      | `2`             | number of web workers to spawn                     |
| workerScript | `gif.worker.js` | url to load worker script from                     |
| background   | `#fff`          | background color where source image is transparent |
| width        | `null`          | output image width                                 |
| height       | `null`          | output image height                                |
| transparent  | `null`          | transparent hex color, `0x00FF00` = green          |
| dither       | `false`         | dithering method, e.g. `FloydSteinberg-serpentine` |
| debug        | `false`         | whether to print debug information to console      |

If width or height is `null` image size will be deteremined by first frame added.

Available dithering methods are:

 * `FloydSteinberg`
 * `FalseFloydSteinberg`
 * `Stucki`
 * `Atkinson`

You can add `-serpentine` to use serpentine scanning, e.g. `Stucki-serpentine`.

### addFrame options

| Name         | Default         | Description                                        |
| -------------|-----------------|----------------------------------------------------|
| delay        | `500`           | frame delay                                        |
| copy         | `false`         | copy the pixel data                                |


## Acknowledgements

gif.js is based on:

 * [Kevin Weiner's Animated gif encoder classes](http://www.fmsware.com/stuff/gif.html)
 * [Neural-Net color quantization algorithm by Anthony Dekker](http://members.ozemail.com.au/~dekker/NEUQUANT.HTML)
 * [Thibault Imbert's as3gif](https://code.google.com/p/as3gif/)

Dithering code contributed by @PAEz and @panrafal


## License

The MIT License (MIT)

Copyright (c) 2013 Johan Nordberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
