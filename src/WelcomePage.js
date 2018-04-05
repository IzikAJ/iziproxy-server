import React, { Component } from 'react';
import { Link } from 'react-router-dom'

export class WelcomePage extends Component {
  constructor(props) {
    super(props);

    this.state = {
    };
  }

  renderAuthorizedContent() {
    return (
      <Link to="/profile">profile</Link>
    );
  }
  renderUnauthorizedContent() {
    return (
      <Link to="/login">login</Link>
    );
  }

  render() {
    return (
      <div>
        Welcome
        {JSON.stringify(this.props)}
        <hr/>
        {this.props.user ? this.renderAuthorizedContent() : this.renderUnauthorizedContent()}
      </div>
    );
  }
}

export default WelcomePage;
