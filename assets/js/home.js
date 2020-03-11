import React from 'react';
import Board from './board';
import { tiles, items } from './map';


export default function(props) {
  return <div className='container home'>
    <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>

    <div className='instructions-container'>
      <p><span>Disease it</span> est un jeu <span>multijoueur</span> jouable dans le navigateur.
      Chaque joueur y incarne une maladie et cherche à <span>contaminer le plus d'humains possible</span> avant de rallier le port pour s'étendre.</p>

      <div className="button enabled" onClick={props.openLobbyClicked}>Commencer à jouer</div>
    </div>

    <Board width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 100} originY={900/2 - 30} />
  </div>;
}
