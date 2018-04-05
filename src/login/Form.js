import React, { Component } from 'react';
import axios from 'axios';
import {
  Redirect
} from 'react-router-dom'
import './Form.css';
import DisplayErrors from '../utils/DisplayErrors.js';
import { User } from '../models/user';

export class Form extends Component {
  constructor(props) {
    super(props);

    this.state = {
      signed: false
    };

    this.user = User.instance;

    // console.log('???', User.instance);

    this.onChange = this.onChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }

  onChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;

    this.setState({
      [name]: value
    });
  }

  onSubmit(event) {
    console.log('onSubmit');
    event.preventDefault();
    if (!this.state.loading) {
      this.sendData();
    }
  }

  sendData() {
    this.setState({loading: true});
    axios.post('/api/session.json', {
      email: this.state.email,
      password: this.state.password,
    }).then(res => {
      console.log('sendData', res);
      this.user.token = res.token;

      axios.get('/api/session.json').then(session => {
        const user = (session.user && session.user.id) ? session.user : null;
        this.setState({
          loading: false,
          signed: true,
        });
        this.props.onLoginSuccess(user, {session});
      }).catch((fail) => {
        console.log('FAIL session:', fail);
        this.setState({loading: false, signed: false});
      });
    }).catch((fail) => {
      console.log('FAIL auth:', fail);
      this.setState({
        loading: false,
        signed: false,
        errors: fail.errors
      });
    });
  }

  getFieldError(...fieldNames) {
    if (this.state.errors) {
      for (let fieldName of fieldNames) {
        if (fieldName in this.state.errors) {
          return this.state.errors[fieldName];
        }
      }
    }
  }

  renderSubmit() {
    if (this.state.loading) {
      return (
        <input type="submit" disabled value="Sending..." />
      );
    } else {
      return (
        <input type="submit" value="Send" />
      );
    }
  }

  render() {
    if (this.state.signed) {
      return (<Redirect to="/profile"/>);
    } else {
      return (
        <form className="Form" onSubmit={this.onSubmit}>
          <div className="field_item">
            <label htmlFor="user_email">Email:</label>
            <DisplayErrors error={this.getFieldError('email', 'base')}>
              <input type="email" name="email" id="user_email"
                     onChange={this.onChange} />
           </DisplayErrors>
          </div>
          <div className="field_item">
            <label htmlFor="user_password">Password:</label>
            <DisplayErrors error={this.getFieldError('password')}>
              <input type="password" name="password" id="user_password"
                     onChange={this.onChange} />
            </DisplayErrors>
          </div>
          <div className="field_item">
            {this.renderSubmit()}
          </div>
        </form>
      );
    }
  }
}

export default Form;
