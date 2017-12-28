import React, { Component } from 'react';
import './Form.css';

export class Form extends Component {
  render() {
    return (
      <form className="Form">
        <div class="field_item">
          <label for="user_email">Email:</label>
          <input type="email" name="user[email]" id="user_email" />
        </div>
        <div class="field_item">
          <label for="user_password">Password:</label>
          <input type="password" name="user[password]" id="user_password" />
        </div>
        <div class="field_item">
          <input type="submit" value="Submit" />
        </div>
      </form>
    );
  }
}

export default Form;
