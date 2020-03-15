window.sounds = {};


function preloadImage(url) {
  const image = new Image();
  image.src = url;
}


function preloadSound([ id, url ]) {
  window.sounds[id] = new Audio(url);
}


setTimeout(function () {
  [].map(preloadImage);

  [
    [ 'horn', '/audio/horn.mp3' ],
    [ 'dicesRoll', '/audio/dices-roll.mp3' ],
    [ 'crowdPanic', '/audio/crowd-panic.mp3' ],
    [ 'shipBell', '/audio/ship-bell.mp3' ],
  ].map(preloadSound);
}, 500);
