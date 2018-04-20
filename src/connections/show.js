import React, { Component } from 'react';

import {
  Link,
} from 'react-router-dom'

import { User } from '../_models/user';

export class Show extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      items: [],
    };
    this.uuid = props.match.params.id;

    User.hook(this, user => {
      this.setState({
        user,
        loading: false,
      });
    });
  }

  componentDidMount() {
    if (this.uuid) {
      console.log('JOIN TO CLIENT', this.uuid);
      User.instance.subscribeClientLog(this.uuid);
      this._sub = User.instance.sockOn({
        filter: (log) => log.kind === 'client' && log.target === this.uuid
      }).subscribe(message => {
        if (message.type === 'blob' && message.at === 'recived') {
          this.setState({
            items: this.state.items.map((item) => {
              if (item.uuid === message.uuid) {
                return {...item, ...message};
              } else {
                return item
              }
            })
          });
        } else {
          this.setState({
            items: [message, ...this.state.items]
          });
        }
      });
    }
  }

  componentWillUnmount() {
    if (this.uuid) {
      console.log('LEAVE CLIENT', this.uuid);
      User.instance.unsubscribeClientLog(this.uuid);
      this._sub.unsubscribe();
    }
  }

  renderBlob(item) {
    return (
      <div>
        { item.status ? `[${item.status}]` : '' }
        { (item.at === 'sent') ? '...' : '' }
        { item.method }:
        { item.path }
      </div>
    );
  }

  renderLogItem(item) {
    let inner = null;
    switch (item.type) {
      case 'blob':
        inner = this.renderBlob(item);
        break;
      default:
        inner = item.message;
        break;
    }
    return (
      <div key={item.id || Math.random().toString(36).slice(2,12)}>
        { inner || 'TODO' }
        <p style={ {display: 'none'} }>{ JSON.stringify(item) }</p>
      </div>
    );
  }

  render() {
    return (
      <div>
        <Link to="/connections">
          back
        </Link>
        <p>TODO: /connections/show</p>
        { this.state.items.map(item => this.renderLogItem(item)) }
      </div>
    );
  }
}
