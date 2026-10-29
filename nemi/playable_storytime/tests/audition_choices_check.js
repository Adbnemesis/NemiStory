/* Behavior checks for the local audition controls. Actual decoded media and
 * browser focus/painting are checked separately in the real preview. */
'use strict';
const assert = require('assert/strict');
const {createAuditionChoices} = require(process.argv[2]);

const ORIGIN = 'http://127.0.0.1:8768';
const SPHERE = '/episodes/episode_002/renders/NEMI_Drawing_Escape_audition_r3_2160x1080_360_REVIEW.mp4';
const DIRECTED = '/episodes/episode_002/renders/NEMI_Drawing_Escape_audition_r3_1080p_REVIEW.mp4';
const R4_SPHERE = SPHERE.replace('_r3_', '_r4_');
const R4_DIRECTED = DIRECTED.replace('_r3_', '_r4_');
global.location = {origin: ORIGIN, href: ORIGIN + '/previews/audition.html'};

class Events {
  constructor() { this.listeners = new Map(); }
  addEventListener(name, fn) {
    const list = this.listeners.get(name) || [];
    list.push(fn); this.listeners.set(name, list);
  }
  removeEventListener(name, fn) {
    this.listeners.set(name, (this.listeners.get(name) || []).filter(item => item !== fn));
  }
  fire(name, input = {}) {
    const event = {target: this, ...input};
    for (const fn of this.listeners.get(name) || []) fn(event);
    return event;
  }
}
class Element extends Events {
  constructor(tagName = 'DIV', type = '') {
    super(); this.tagName = tagName; this.nodeName = tagName; this.type = type;
    this.disabled = false; this.hidden = false; this.textContent = '';
    this.isContentEditable = false; this.attributes = {}; this.dataset = {};
    this.classList = {add() {}, remove() {}, toggle() {}};
  }
  setAttribute(key, value) { this.attributes[key] = String(value); }
  removeAttribute(key) { delete this.attributes[key]; }
  getAttribute(key) { return this.attributes[key] ?? null; }
  get isContentEditable() { return this._editable || Boolean(this.parentElement?.isContentEditable); }
  set isContentEditable(value) { this._editable = Boolean(value); }
  closest() {
    if (this.isContentEditable || ['TEXTAREA', 'SELECT'].includes(this.tagName)) return this;
    if (this.tagName === 'INPUT' && this.type !== 'range') return this;
    return this.parentElement?.closest() || null;
  }
  focus() { this.focused = true; }
}
class Video extends Element {
  constructor(url, duration = 40) {
    super('VIDEO'); this.src = this.currentSrc = url; this.duration = duration;
    this.currentTime = 0; this.paused = true; this.ended = false;
    this.readyState = Number.isFinite(duration) ? 2 : 0; this.seeking = false;
    this.plays = 0; this.pauses = 0; this.rejectPlay = false;
  }
  play() {
    this.plays++;
    if (this.rejectPlay) return Promise.reject(new Error('Browser requires Play'));
    this.paused = false; this.ended = false; this.fire('play');
    return Promise.resolve();
  }
  pause() { this.pauses++; this.paused = true; this.fire('pause'); }
}
function fixture({path = R4_SPHERE, duration = 40, ready = true} = {}) {
  const url = ORIGIN + path, video = new Video(url, duration), eventTarget = new Events();
  const panel = new Element(), feedback = new Element(), scope = new Element();
  const doorButton = new Element('BUTTON'), tearButton = new Element('BUTTON');
  const restartButton = new Element('BUTTON');
  const turns = [], restarts = [];
  const controller = createAuditionChoices({video, panel, feedback, doorButton,
    tearButton, restartButton, scope, eventTarget,
    onChoose(route) { turns.push({...route}); },
    onRestart() { restarts.push(true); }});
  controller.setSource(url);
  if (ready) { video.fire('loadedmetadata'); controller.loadedMetadata(); }
  return {video, eventTarget, controller, panel, feedback, scope, doorButton, tearButton, restartButton, turns, restarts};
}
function key(f, value, target = new Element('BODY'), extra = {}) {
  let prevented = false;
  f.eventTarget.fire('keydown', {key: value, code: 'Digit' + value, target,
    ctrlKey: false, altKey: false, metaKey: false, repeat: false, isComposing: false,
    preventDefault() { prevented = true; }, stopPropagation() {}, ...extra});
  return prevented;
}
const flush = () => new Promise(resolve => setImmediate(resolve));

(async () => {
  // The known short file has local 20/30-second entries; no percentage map is
  // inferred from duration and no unrelated movie receives those destinations.
  for (const path of [SPHERE, DIRECTED, R4_SPHERE, R4_DIRECTED]) {
    const f = fixture({path}); assert(f.controller.isActive());
    const targetYaw = path.includes('_r4_') ? 76 : 34.5;
    assert(!f.doorButton.disabled); assert(!f.tearButton.disabled);
    assert(key(f, '1')); await flush();
    assert.equal(f.video.currentTime, 20); assert.equal(f.video.paused, false);
    assert.equal(f.video.plays, 1); assert(f.controller.hasSelection());
    assert.deepEqual(f.turns, [{key: 1, at: 20, name: 'Door', yaw: -targetYaw, pitch: 0}]);
    assert.match(f.feedback.textContent, /door|\b1\b/i);
    assert(key(f, '2')); await flush();
    assert.equal(f.video.currentTime, 30); assert.equal(f.video.paused, false);
    assert.match(f.feedback.textContent, /tear|\b2\b/i);
    assert.deepEqual(f.turns[1], {key: 2, at: 30, name: 'Tear', yaw: targetYaw, pitch: 0});
  }
  for (const path of ['/unrelated.mp4', SPHERE.replace('episode_002', 'episode_001'), SPHERE.replace('r3_', 'r2_')]) {
    const f = fixture({path}); assert(!f.controller.isActive());
    assert(f.doorButton.disabled); assert(f.tearButton.disabled);
    key(f, '1'); f.doorButton.fire('click');
    assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0);
  }
  for (const duration of [NaN, 0, Infinity, 39.9, 40.1, 240]) {
    const f = fixture({duration}); assert(!f.controller.isActive());
    const rejectedMessage = f.feedback.textContent;
    key(f, '2'); assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.feedback.textContent, rejectedMessage, 'Rejected media must not queue a loading choice');
    assert(!f.controller.hasSelection());
    assert.equal(f.turns.length, 0);
  }

  // A selection can be made before metadata, but it is not performed until
  // the matching duration arrives. A second selection replaces the first.
  for (const path of [SPHERE, R4_SPHERE]) {
    const f = fixture({path, duration: NaN, ready: false});
    key(f, '1'); key(f, '2');
    assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0, 'Loading must not turn before the media contract is known');
    f.video.duration = 40; f.video.readyState = 2; f.video.fire('loadedmetadata');
    await flush(); assert.equal(f.video.currentTime, 30); assert.equal(f.video.plays, 1);
    assert.deepEqual(f.turns, [{key: 2, at: 30, name: 'Tear', yaw: path === R4_SPHERE ? 76 : 34.5, pitch: 0}]);
    f.controller.loadedMetadata(); await flush();
    assert.equal(f.video.plays, 1, 'The queued selection must run only once');
    assert.equal(f.turns.length, 1, 'The latest queued viewpoint must be applied once');
  }
  {
    const f = fixture({path: '/unrelated.mp4', duration: NaN, ready: false});
    key(f, '1'); f.video.duration = 40; f.video.readyState = 2; f.video.fire('loadedmetadata');
    await flush(); assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0);
  }

  // Every stable player focus target keeps number input working. This includes
  // the range slider; it is not treated like a field for typing a document.
  for (const target of [new Element('BODY'), new Element('CANVAS'), new Element('INPUT', 'range'),
    new Element('BUTTON'), new Element('VIDEO')]) {
    const f = fixture(); assert(key(f, '1', target)); await flush();
    assert.equal(f.video.currentTime, 20); assert.equal(f.video.plays, 1);
    assert.equal(f.turns[0].yaw, -76);
    assert(key(f, '2', target, {code: 'Numpad2'})); await flush();
    assert.equal(f.video.currentTime, 30);
    assert.equal(f.turns[1].yaw, 76);
  }
  const editable = new Element(); editable.isContentEditable = true;
  const editableChild = new Element('SPAN'); editableChild.parentElement = editable;
  for (const target of [new Element('INPUT', 'text'), new Element('TEXTAREA'),
    new Element('SELECT'), editable, editableChild]) {
    const f = fixture(); key(f, '1', target);
    assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0, 'Typing in an editable element must not turn the view');
  }
  for (const extra of [{ctrlKey: true}, {altKey: true}, {metaKey: true}, {repeat: true}, {isComposing: true}]) {
    const f = fixture(); key(f, '1', undefined, extra);
    assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0);
  }
  for (const value of ['0', '3', '!', 'a']) {
    const f = fixture(); key(f, value);
    assert.equal(f.video.currentTime, 0); assert.equal(f.video.plays, 0);
    assert.equal(f.turns.length, 0);
  }

  // Buttons and keys invoke the same action; a rapid later choice owns the
  // position even when an earlier seek completion is delivered afterwards.
  {
    const f = fixture(); f.doorButton.fire('click'); await flush();
    assert.equal(f.video.currentTime, 20);
    f.tearButton.fire('click');
    f.video.seeking = true; f.video.fire('seeked'); f.video.fire('seeking');
    assert(f.controller.hasSelection(), 'An old completion must not release the latest route while it is seeking');
    f.video.seeking = false; f.video.fire('seeked'); await flush();
    assert.equal(f.video.currentTime, 30); assert(!f.video.paused);
    assert.deepEqual(f.turns.map(route => route.yaw), [-76, 76]);
    f.video.currentTime = 35; f.controller.guardBoundary();
    assert.equal(f.video.currentTime, 35, 'Old door boundary must not truncate the tear route');
  }
  {
    const f = fixture(); key(f, '1'); await flush();
    f.video.currentTime = 29.89; f.controller.guardBoundary(); assert(!f.video.paused);
    f.video.currentTime = 29.95; f.controller.guardBoundary();
    assert(f.video.paused); assert.equal(f.video.currentTime, 29.9);
    assert.match(f.feedback.textContent, /tear|\b2\b|again|retry/i);
    key(f, '2'); await flush(); assert.equal(f.video.currentTime, 30); assert(!f.video.paused);
  }
  {
    const f = fixture(); f.video.paused = false; f.video.currentTime = 29.95;
    f.controller.guardBoundary(); assert(!f.video.paused); assert.equal(f.video.currentTime, 29.95);
    assert(!f.controller.hasSelection(), 'Passive play remains one continuous audition');
  }

  // Replaying from the beginning resets route ownership and does not silently
  // retain a stop at the previous door ending.
  {
    const f = fixture(); key(f, '1'); await flush(); f.controller.reset();
    assert.equal(f.video.currentTime, 0); assert(f.video.paused); assert(!f.controller.hasSelection());
    assert.equal(f.restarts.length, 1, 'Restart must request forward orientation');
    assert.equal(f.controller.focusYaw(), 0);
    key(f, '2'); await flush(); f.restartButton.fire('click');
    assert.equal(f.video.currentTime, 0); assert(f.video.paused); assert(!f.controller.hasSelection());
    assert.equal(f.restarts.length, 2);
    assert.equal(f.controller.focusYaw(), 0);
  }
  // Face Nemi follows the actor's current authored wall, rather than always
  // forcing the old forward view after an outcome moved her into a side set.
  {
    const f = fixture();
    for (const [at, yaw] of [[0, 0], [19.999, 0], [20, -93.6], [29.9, -93.6], [30, 92.4], [40, 92.4]]) {
      f.video.currentTime = at;
      assert.equal(f.controller.focusYaw(), yaw);
    }
    f.controller.setSource(ORIGIN + SPHERE); f.controller.loadedMetadata();
    for (const at of [0, 20, 30, 40]) {
      f.video.currentTime = at;
      assert.equal(f.controller.focusYaw(), 0, 'R3 keeps its original front-facing actor');
    }
    key(f, '1'); key(f, '2'); await flush();
    assert.deepEqual(f.turns.slice(-2).map(route => route.yaw), [-34.5, 34.5], 'Changing source must restore its own legacy target angles');
  }
  {
    const f = fixture(); f.video.rejectPlay = true; key(f, '2'); await flush();
    assert.equal(f.video.currentTime, 30); assert(f.video.paused);
    assert.match(f.feedback.textContent, /play/i, 'A browser playback rejection must give a recovery action');
  }
  {
    const f = fixture();
    let rejectDoor;
    f.video.play = () => { f.video.paused = false; return new Promise((resolve, reject) => { rejectDoor = reject; }); };
    key(f, '1');
    const firstFailure = rejectDoor;
    f.video.play = () => { f.video.paused = false; return Promise.resolve(); };
    key(f, '2');
    firstFailure(new Error('Earlier door playback failed'));
    await flush();
    assert.equal(f.video.currentTime, 30);
    assert.match(f.feedback.textContent, /2.*Tear selected.*playing/i);
  }
  {
    const f = fixture(); key(f, '1'); await flush();
    f.video.fire('seeked'); f.video.currentTime = 35; f.video.fire('seeking');
    assert(!f.controller.hasSelection(), 'A manual seek releases the selected route boundary');
    f.controller.guardBoundary(); assert.equal(f.video.currentTime, 35);
  }
  {
    const f = fixture(); key(f, '1'); await flush(); f.video.fire('error');
    assert(!f.controller.isActive()); assert(f.doorButton.disabled); assert(f.tearButton.disabled);
    const failedMessage = f.feedback.textContent;
    const before = f.video.currentTime; key(f, '2'); assert.equal(f.video.currentTime, before);
    assert.equal(f.feedback.textContent, failedMessage);
    assert(!f.controller.hasSelection());
  }
  console.log('Audition choice checks passed: R3/R4 entries and viewpoint callbacks, source-specific focus, media guards, queued startup, focus/typing guards, buttons, retry boundary, passive playback, restart orientation and Play recovery.');
})().catch(error => { console.error(error); process.exitCode = 1; });
