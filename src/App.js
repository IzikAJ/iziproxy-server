import React, { Component } from 'react';
// import logo from './logo.svg';
import './App.css';
import { Root as Welcome } from './welcome/root';
import { Form as LoginForm } from './login/Form.js';
import { Root as Connections } from './connections/root';
import { Root as Profile } from './profile/root';
import { PageNotFound } from './shared/page-not-found';
import { Api } from './_utils/api';
import { User } from './_models/user';

import {
  Route,
  Switch,
  Redirect
} from 'react-router-dom'

export class App extends Component {
  constructor(props) {
    super(props);

    this.user = User.instance;
    this.authLoading = true;
    this.state = {
      data: {},
    };

    this.logOut = this.logOut.bind(this);
  }

  logOut() {
    Api.session.destroy().then(session => {
      this.onCurrUserUpdate(null, {session});
    });
  }

  onCurrUserUpdate(user, extra_params = {}) {
    this.setState({
      ...extra_params,
      user: user
    }, () => {
      if ('callback' in extra_params) {
        extra_params.callback();
      }
    });
  }

  componentDidMount() {
    Api.session.show().then(session => {
      this.authLoading = false;
      const user = (session.user && session.user.id) ? session.user : null;
      this.onCurrUserUpdate(user, {session});
    }).catch(err => {
      console.log('SESSION FAIL:', err);
    });
  }

  renderLoginForm() {
    return (
      <div>
        <p className="App-intro">
          Please login first
        </p>
        <LoginForm onLoginSuccess={(usr, params = {}) => this.onCurrUserUpdate(usr, params)}/>
      </div>
    );
  }

  renderGreeting(user) {
    return (
      <div>
        <span>Hello {user.name || user.email || 'User'}</span>
        <button onClick={ this.logOut }>Log out</button>
        <Profile />
      </div>
    );
  }

  renderLoader() {
    return (
      <span>Loading...</span>
    );
  }

  renderAuthorizedRoutes() {
    return (
      <Switch>
        <Route
          path="/profile"
          render={
            (props) => this.renderGreeting(this.state.user)
          }
        />
        <Route
          path="/connection(s|)"
          component={ Connections }
        />
        <Redirect from="/login" to="/profile"/>
      </Switch>
    );
  }

  renderUnauthorizedRoutes() {
    return (
      <Switch>
        <Redirect
          from="/profile"
          to="/login"
        />
        <Redirect
          from="/connection(s|)"
          to="/login"
        />
        <Route
          path="/login"
          render={ (props) => this.renderLoginForm(props) }
        />
      </Switch>
    );
  }

  renderContent() {
    if (this.authLoading) {
      return this.renderLoader();
    } else {
      return (
        <Switch>
          <Route
            exact
            path="/"
            component={ Welcome }
          />
          {
            this.state.user ?
              this.renderAuthorizedRoutes() :
              this.renderUnauthorizedRoutes()
          }
          <Route component={ PageNotFound }/>
        </Switch>
      );
    }
  }

  render() {
    return (
      <div className="App">
        {
          this.renderContent()
        }
      </div>
    );
  }
}

export default App;
