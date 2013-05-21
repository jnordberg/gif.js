
```javascript
var gif = new GIF({
  workers: 2,
  quality: 10
});

// add a image element
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
