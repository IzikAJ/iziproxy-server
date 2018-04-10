import React, { Component } from 'react';

import {
  Route, Switch, Link,
} from 'react-router-dom'

import { User } from '../_models/user';
import { Show } from './show';
import { Edit } from './edit';

export class Root extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true
    };

    User.hook(this, user => {
      this.setState({
        user,
        loading: false
      });
    });
  }

  render() {
    return (
      <div>
        <h1>TODO</h1>
        <ul>
          <li>
            <Link to="/profile">Show</Link>
          </li>
          <li>
            <Link to="/profile/edit">Edit</Link>
          </li>
        </ul>

        <Switch>
          <Route
            path="/profile"
            exact
            component={ Show }
          />
          <Route
            path="/profile/edit"
            component={ Edit }
          />
        </Switch>
      </div>
    );
  }
}
