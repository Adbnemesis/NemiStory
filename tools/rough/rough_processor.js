const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const rough = require('roughjs');

/**
 * Utility to generate hand-drawn SVG vector assets using Rough.js.
 * Signature outline color: #3e081e (deep wine/burgundy)
 */
const LINE_COLOR = '#3e081e';

function createHandDrawnSpeechBubble(width = 320, height = 180, tailSide = 'bottom-left') {
  const dom = new JSDOM('<!DOCTYPE html><html><body><svg></svg></body></html>');
  const svg = dom.window.document.querySelector('svg');
  svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
  svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
  svg.setAttribute('width', width);
  svg.setAttribute('height', height);

  const rc = rough.svg(svg);

  // Bubble body
  const bubble = rc.ellipse(width / 2, (height - 30) / 2, width - 40, height - 60, {
    stroke: LINE_COLOR,
    strokeWidth: 3.5,
    roughness: 1.2,
    bowing: 1.5,
    fill: '#ffffff',
    fillStyle: 'solid'
  });
  svg.appendChild(bubble);

  // Bubble tail pointing down-left
  const tail = rc.polygon([[80, height - 40], [50, height - 5], [115, height - 38]], {
    stroke: LINE_COLOR,
    strokeWidth: 3.5,
    roughness: 1.2,
    fill: '#ffffff',
    fillStyle: 'solid'
  });
  svg.appendChild(tail);

  return svg.outerHTML;
}

function createHandDrawnDoodleBox(width = 240, height = 140) {
  const dom = new JSDOM('<!DOCTYPE html><html><body><svg></svg></body></html>');
  const svg = dom.window.document.querySelector('svg');
  svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
  svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
  svg.setAttribute('width', width);
  svg.setAttribute('height', height);

  const rc = rough.svg(svg);
  const box = rc.rectangle(10, 10, width - 20, height - 20, {
    stroke: LINE_COLOR,
    strokeWidth: 3.0,
    roughness: 1.8,
    bowing: 2.0
  });
  svg.appendChild(box);

  return svg.outerHTML;
}

if (require.main === module) {
  const outDir = path.resolve(__dirname, '../../assets/props');
  fs.mkdirSync(outDir, { recursive: true });

  const bubbleSvg = createHandDrawnSpeechBubble();
  fs.writeFileSync(path.join(outDir, 'speech_bubble_rough.svg'), bubbleSvg);
  console.log('Generated speech_bubble_rough.svg using Rough.js');

  const doodleDir = path.resolve(__dirname, '../../assets/doodles');
  fs.mkdirSync(doodleDir, { recursive: true });
  const boxSvg = createHandDrawnDoodleBox();
  fs.writeFileSync(path.join(doodleDir, 'doodle_box_rough.svg'), boxSvg);
  console.log('Generated doodle_box_rough.svg using Rough.js');
}

module.exports = {
  createHandDrawnSpeechBubble,
  createHandDrawnDoodleBox
};
