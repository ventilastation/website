'use strict';

Reveal.initialize({
  width: 1280,
  height: 720,
  margin: 0.04,
  center: false,
  hash: true,
  history: true,
  transition: 'fade',
  transitionSpeed: 'fast',
  controls: true,
  controlsTutorial: false,
  progress: true,
  slideNumber: 'c/t',
  totalTime: 30 * 60,
  pdfSeparateFragments: false,
  pdfMaxPagesPerSlide: 1,
  plugins: [RevealMarkdown, RevealHighlight, RevealNotes]
}).then(function () {
  document.body.classList.add('deck-ready');
}).catch(function () {
  var message = document.createElement('p');
  message.className = 'fallback';
  message.innerHTML = 'The slides could not start. <a href="handout.html">Open the reading view and notes</a>.';
  document.body.appendChild(message);
});
