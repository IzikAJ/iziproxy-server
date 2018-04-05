import React, { Component } from 'react';
// import logo from './logo.svg';
import './App.css';
import { WelcomePage } from './WelcomePage.js';
import { Form as LoginForm } from './login/Form.js';
import { Profile as ProfileForm } from './Profile.js';
import { PageNotFound } from './PageNotFound.js';
import ApiConfig from './utils/api_config';
import axios from 'axios';

import {
  Route,
  Switch,
  Redirect
} from 'react-router-dom'

class App extends Component {
  constructor(props) {
    super(props);

    this.authLoading = true;
    this.state = {
      data: {},
      apiConfig: new ApiConfig()
    };

    this.logOut = this.logOut.bind(this);
  }

  logOut() {
    axios.delete('/api/session.json').then(session => {
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
    axios.get('/api/session.json').then(session => {
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
        <ProfileForm />
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
        <Redirect from="/login" to="/profile"/>
      </Switch>
    );
  }

  renderUnauthorizedRoutes() {
    return (
      <Switch>
        <Redirect from="/profile" to="/login"/>
        <Route path="/login" render={(props) => this.renderLoginForm(props) }/>
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
            render={
              (props) => <WelcomePage user={ this.state.user } />
            }
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
