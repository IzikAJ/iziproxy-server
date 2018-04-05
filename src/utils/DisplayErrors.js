import React, { Component } from 'react';

export class DisplayErrors extends Component {
  constructor(props) {
    super(props);

    this.state = {
    };
  }

  getErrorMessage(error) {
    return error;
  }

  renderValid() {
    return this.props.children;
  }

  renderInvalid(error) {
    return (
      <div className="hasError">
        {this.props.children}
        <span className="errorMessage">
          {this.getErrorMessage(error)}
        </span>
      </div>
    );
  }

  render() {
    if (this.props.error) {
      return this.renderInvalid(this.props.error);
    } else  {
      return this.renderValid();
    }
  }
}

export default DisplayErrors;
