
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
