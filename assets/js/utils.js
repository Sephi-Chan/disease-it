function remap(value, min1, max1, min2, max2) {
  return (value - min1) * (max2 - min2) / (max1 - min1) + min2;
}


function objectFromArray(array) {
  return array.reduce(function(acc, item) {
    acc[item] = true;
    return acc;
  }, {});
}


function parseTile(tileAsString) {
  return tileAsString.split('_').map(i => parseInt(i));
}


export { remap, objectFromArray, parseTile };
