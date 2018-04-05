import React, { Component } from 'react';
import axios from 'axios';
import { User } from '../models/user';

import { DisplayErrors } from '../utils/DisplayErrors.js';

export class Edit extends Component {
  constructor(props) {
    super(props);

    this.state = {
      user: {},
      loading: true
    };

    this.onChange = this.onChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);

    User.hook(this, user => {
      this.setState({
        user,
        loading: false
      });
    });
  }

  onChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? !!target.checked : target.value;
    const name = target.name;

    this.setState({
      user:{
        ...this.state.user,
        [name]: value
      }
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
    axios.post('/api/profile.json', {
      name: this.state.user.name,
      email: this.state.user.email,
      password: this.state.user.password,
      log_requests: this.state.user.log_requests,
    }).then(res => {
      console.log('PROFILE UPD: ', res)
      this.setState({
        ...res,
        password: null,
        loading: false,
      });
      User.instance.loadProfile();
    }).catch((fail) => {
      console.log('FAIL:', fail);
      this.setState({
        loading: false,
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

  fieldKey(keyName) {
    if (this.state.loading) {
      return `field_${keyName}_loading`;
    } else {
      return `field_${keyName}`;
    }
  }

  render() {
    return (
      <form className="Form" onSubmit={this.onSubmit}>
        {JSON.stringify(this.state)}
        <div className="field_item">
          <label htmlFor="user_name">Name:</label>
          <DisplayErrors error={this.getFieldError('name', 'base')}>
            <input
              type="name"
              name="name"
              id="user_name"
              defaultValue={this.state.user.name}
              key={this.fieldKey('name')}
              disabled={this.state.loading}
              autoComplete="false"
              onChange={this.onChange}
            />
         </DisplayErrors>
        </div>

        <div className="field_item">
          <label htmlFor="user_email">Email:</label>
          <DisplayErrors error={this.getFieldError('email', 'base')}>
            <input
              type="email"
              name="email"
              id="user_email"
              defaultValue={this.state.user.email}
              autoComplete="new-email"
              key={this.fieldKey('email')}
              disabled={this.state.loading}
              onChange={this.onChange}
            />
         </DisplayErrors>
        </div>

        <div className="field_item">
          <label htmlFor="user_log_requests">Log requests:</label>
          <input
            type="checkbox"
            name="log_requests"
            id="user_log_requests"
            defaultChecked={this.state.user.log_requests}
            disabled={this.state.loading}
            key={this.fieldKey('log_requests')}
            onClick={this.onChange}
            onChange={this.onChange}
          />
        </div>

        <div className="field_item">
          <label htmlFor="user_password">Password:</label>
          <DisplayErrors error={this.getFieldError('password')}>
            <input
              type="password"
              name="password"
              id="user_password"
              defaultValue=""
              autoComplete="new-password"
              key={this.fieldKey('password')}
              disabled={this.state.loading}
              onChange={this.onChange}
            />
          </DisplayErrors>
        </div>

        <div className="field_item">
          {this.renderSubmit()}
        </div>
      </form>
    );
  }
}

export default Edit;
