import React, { Component } from 'react';
import {
  Route, Switch, Link,
} from 'react-router-dom'

import { User } from '../_models/user';
import { Show } from './show';
import { List } from './list';

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
        <Link to="/profile">Profile</Link>

        <Switch>
          <Route
            path={this.props.match.url}
            exact
            component={ List }
          />
          <Route
            path={this.props.match.url + '/:id'}
            component={ Show }
          />
        </Switch>
      </div>
    );
  }
}
