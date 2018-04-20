import React, { Component } from 'react';
import { Api } from '../../_utils/api';

export class RequestTokens extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      tokens: [],
    };

    this._fetchTokens();
    this.onCreateToken = this.onCreateToken.bind(this);
    this.onRemoveToken = this.onRemoveToken.bind(this);
  }

  _fetchTokens() {
    Api.profile.tokens.list().then(tokens => {
      this.setState({loading: false, tokens});
    }).catch(err => {
      this.setState({loading: false});
    });
  }

  onCreateToken(evt) {
    if (this.state.loading) { return; }
    this.setState({loading: true});
    Api.profile.tokens.create().then(token => {
      this.setState({
        loading: false,
        tokens: [
          ...this.state.tokens,
          token,
        ]
      });
    }).catch(err => {
      this.setState({loading: false});
      console.log('FAIL: onCreateToken', err);
    });
  }

  onRemoveToken(evt, token) {
    if (this.state.loading) { return; }
    this.setState({loading: true});
    Api.profile.tokens.destroy(token.id).then(token => {
      this.setState({
        tokens: this.state.tokens.filter(i => i.id !== token.id),
        loading: false,
      });
    }).catch(err => {
      this.setState({loading: false});
      console.log('FAIL: onRemoveToken', err);
    });
  }

  renderTokens(item) {
    return this.state.tokens.map((item) => {
      return (
        <div key={item.id}>
          id: {item.id}
          <br />
          token:
          <input
            type="text"
            readOnly
            value={item.token}
          />
          <br />
          exp:{ item.expired_at }
          <br />
          <span
            onClick={ (evt) => this.onRemoveToken(evt, item) }
          >x</span>
        </div>
      );
    });
  }

  render() {
    return (
      <div>
        TODO
        profile/stats/request-tokens
        <div>
          { this.renderTokens() }
        </div>
        <span
          onClick={this.onCreateToken}
        >+</span>
      </div>
    );
  }
}
