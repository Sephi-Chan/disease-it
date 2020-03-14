window.sounds = {};


function preloadImage(url) {
  const image = new Image();
  image.src = url;
}


function preloadSound([ id, url ]) {
  window.sounds[id] = new Audio(url);
}


setTimeout(function () {
  [
    "/images/ui/lobby/start-game.png",
  ].map(preloadImage);

  [
    [ 'horn', '/audio/horn.mp3' ],
    [ 'dices_roll', '/audio/dices_roll.mp3' ],
  ].map(preloadSound);
}, 500);
