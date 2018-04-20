import React, { Component } from 'react';
import { ServerLog } from './stats/server-log';
import { RequestTokens } from './stats/request-tokens';
import { User } from '../_models/user';

export class Show extends Component {
  constructor(props) {
    super(props);

    this.state = {
    };

    User.hook(this, user => {
      this.setState({user});
    });
  }

  render() {
    return (
      <div>
        TODO profile/show

        <ServerLog />
        <RequestTokens />
      </div>
    );
  }
}

export default Show;
