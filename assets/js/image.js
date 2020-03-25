import React from 'react';


export default function Image({src, ...others}) {
  console.log(others);

  return <picture>
    <source srcSet={`${src}.webp`} type='image/webp' />
    <img src={src} {...others} />
  </picture>;
}
