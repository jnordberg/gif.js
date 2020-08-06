//`gif.js`只能用于浏览器环境，不适用于node环境

var gif = new GIF({
	repeat: 0, // repeat count, -1 = no repeat, 0 = forever
	workers: 2, // number of web workers to spawn
	workerScript: '../dist/_gif.worker.js',
	quality: 10, // pixel sample interval, lower is better
	background: '#fff', // background color where source image is transparent
	// transparent: null, // transparent hex color, 0x00FF00 = green
	dither: false, // dithering method, e.g. FloydSteinberg-serpentine
	width: 100, // 不指定则自动取第一帧的值
	height: 100, // 不指定则自动取第一帧的值
	globalPalette: [255,255,255, 255,0,0, 0,255,0, 0,0,0], // true 或数组 [r,g,b,r,g,b,...]
});

var frameOptions = {
	copy: true,
	delay: 200,
	dispose: 1,
	localPalette: false,
	left: 0,
	top: 0,
	width: 10,
	height: 10,
};

var canvas = new OffscreenCanvas(100, 100);
var ctx = canvas.getContext('2d');

ctx.fillStyle = '#f00';
ctx.fillRect(0, 0, 40, 40);
gif.addFrame(ctx.getImageData(0, 0, 40, 40), Object.assign({}, frameOptions, { left: 0, top: 0, width: 40, height: 40 }));

ctx.fillStyle = '#0f0';
ctx.fillRect(40, 40, 40, 40);
gif.addFrame(ctx.getImageData(40, 40, 40, 40), Object.assign({}, frameOptions, { left: 40, top: 40, width: 40, height: 40 }));

gif.on('finished', function (blob) {
	// window.open(URL.createObjectURL(blob));
	let src = URL.createObjectURL(blob);
	console.log(src);
});
// http://www.lcdf.org/gifsicle/man.html
// gif生成后，还需要用 gifsicle 优化。
// 单个优化: gifsicle --colors=2 --optimize=3 -i < input.gif > output.gif
// 批量优化: gifsicle --colors=2 --optimize=3 --batch -i *.gif
gif.render();
