import React from 'react';
import { tiles, items } from './map';
import Board from './board';


export default class GameOver extends React.Component {
  constructor(props) {
    super(props);
  }


  render() {
    return <React.Fragment>
      {this.creditsContainer()}
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} />
    </React.Fragment>;
  }


  creditsContainer() {
    return <div className='instructions-container medium'>
      <p><span>Aucune maladie</span> n'a réussi à quitter l'île… Pas une maladie pour rattraper l'autre, si ce n'est dans la médiocrité.</p>
      <p>Vous étiez destinés à de grandes choses comme <span>décimer</span> des populations innocentes, ou encore <span>exterminer</span> des civilisations entières…</p>
      <p>Aujourd'hui, <span>personne</span> ne vous craint : vous êtes aussi <span>inoffensif</span> qu'un bébé chauve-souris.</p>
      <p>Oust… Du balai ! <span>DISPARAISSEZ !!</span></p>
    </div>;
  }
}
