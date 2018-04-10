import React, { Component } from 'react';
import { ServerLog } from './stats/server-log';
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
        TODO
        {JSON.stringify(this.props)}
        <hr />
        {JSON.stringify(this.state)}
        profile/show

        <ServerLog />
      </div>
    );
  }
}

export default Show;
