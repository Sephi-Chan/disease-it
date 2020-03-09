import React from 'react';
import Board from './board';
import { tiles, items } from './map';


export default function(props) {
  return <div className='container home'>
    <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>
    <div className='button enabled' onClick={props.openLobbyClicked}>Commencer une partie</div>
    <Board width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 100} originY={900/2 - 30} />
  </div>;
}
