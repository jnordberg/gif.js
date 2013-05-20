
# gif.js

Full-featured JavaScript GIF encoder that runs in your browser.

Uses typed arrays and web workers to render each frame in the background, it's really fast!

**Demo** - http://jnordberg.github.io/gif.js/

## Usage

Include `gif.js` found in `dist/` in your page. Also make sure to have `gif.worker.js` in the same location.

```javascript
var gif = new GIF({
  workers: 2,
  quality: 10
});

gif.addImage(imageElement);
gif.addImage(canvasElement, 200);
// second argument is delay

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

To set the size of the put image you can use `setSize` if not set it will be determined from the
first frame added.

There are also a few undocumented options, check the source.

## Wishlist

If you want to contribute, here's some stuff that would be nice to have.

 * Tests
 * Fallbacks and polyfills for ~~crappy~~differently abled browsers.

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
