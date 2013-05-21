---
title: Video to GIF
script: video.coffee
template: test.html
---

<p>
  <input disabled id="sample" type="range" step="1" min="20" max="500" value="100">
  <button id="go" disabled>Do it!</button>
</p>

<p id="info">Loading...</p>

<video id="video" width="600">
  <source src="clip.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.'>
  <source src="clip.ogv" type='video/ogg; codecs="theora, vorbis"'>
</video>

<img id="result">

