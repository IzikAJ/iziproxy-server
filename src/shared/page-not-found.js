import React, { Component } from 'react';
import {
  Link
} from 'react-router-dom'

export class PageNotFound extends Component {
  constructor(props) {
    super(props);

    this.state = {
    };
  }

  render() {
    return (
      <div>
        Sorry, PageNotFound
        <Link to="/"></Link>
      </div>
    );
  }
}
