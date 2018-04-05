import React, { Component } from 'react';

import {
  Route,
  Switch,
  Link,
} from 'react-router-dom'

import { User } from './models/user';
import { Show } from './profile/show';
import { Edit } from './profile/edit';

export class Profile extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true
    };
  }

  componentDidMount() {
    User.active.subscribe(user => {
      this.setState({user});
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

export default Profile;
