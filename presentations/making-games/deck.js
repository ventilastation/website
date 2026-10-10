'use strict';

// Everything needed to present is local to this directory.
Reveal.initialize({
  width: 1280,
  height: 720,
  margin: 0.04,
  center: false,
  hash: true,
  history: true,
  view: 'slide',
  transition: 'fade',
  transitionSpeed: 'fast',
  backgroundTransition: 'fade',
  controls: true,
  controlsTutorial: false,
  progress: true,
  slideNumber: 'c/t',
  totalTime: 45 * 60,
  pdfSeparateFragments: false,
  pdfMaxPagesPerSlide: 1,
  highlight: { highlightOnLoad: true },
  plugins: [RevealMarkdown, RevealHighlight, RevealNotes]
}).then(function () {
  document.body.classList.add('deck-ready');
}).catch(function () {
  var message = document.createElement('p');
  message.className = 'fallback';
  message.innerHTML = 'The slide view could not start. <a href="handout.html">Open the reading view and speaker notes</a>.';
  document.body.appendChild(message);
});
