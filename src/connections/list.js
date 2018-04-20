import React, { Component } from 'react';
import { Api } from '../_utils/api';

import {
  Link,
} from 'react-router-dom'

import { User } from '../_models/user';

export class List extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      items: [],
    };

    User.hook(this, user => {
      this.setState({
        user,
        loading: false
      });
    });
    this.loadConnectionsList();
  }

  componentDidMount() {
    this._sub = User.instance.sockOn({
      onConnect: () => {
        console.log('onConnect');
        User.instance.subscribeUserLog();
      },
      filter: (log) => log.kind === 'user'
    }).subscribe(message => {
      console.log('USER SCOPE MESSAGE:', message)
      switch (message.type) {
        case 'authorized':
          this.setState({
            items: [...this.state.items, message]
          });
          break;
        case 'updated':
          this.setState({
            items: this.state.items.map(conn => {
              if (conn.id === message.id) {
                return {
                  ...conn,
                  ...message,
                }
              } else {
                return conn;
              }
            })
          });
          break;
        case 'disconnected':
          this.setState({
            items: this.state.items.filter(c => c.id !== message.id)
          });
          break;
        default:
          break;
      }
    });
  }

  componentWillUnmount() {
    User.instance.unsubscribeUserLog();
    this._sub.unsubscribe();
  }

  loadConnectionsList() {
    Api.profile.connections.list().then(items => {
      console.log('CONNECTIONS', items);
      this.setState({items, loading: false});
    }).catch(err => {
      console.log('CONNECTIONS FAILED');
      this.setState({items: [], loading: false});
    });
  }

  getSubdomainUrl(item) {
    const protocol = window.location.protocol;
    const host = window.location.hostname
    let port = window.location.port;
    if (port === '' || port === '80') { port = null }
    let ans = `${protocol}//${item.subdomain}.${host}`
    if (port) {
      return `${ans}:${port}`;
    }
    return ans;
  }

  itemDetailsPath(item) {
    return `/connection/${item.client_uuid}`;
  }

  renderConnection(item) {
    return (
      <div key={item.id}>
        <Link to={this.itemDetailsPath(item)}>
          <span>[{item.client_uuid}]</span>
        </Link>
        <br />
        <a
          href={this.getSubdomainUrl(item)}
          target="_blank"
          rel="nofollow noopener noreferrer"
        >{item.subdomain}.lvh.me</a>
        <sup>{item.packets_count || 0}</sup>/<sub>{item.errors_count || 0}</sub>
      </div>
    );
  }

  render() {
    return (
      <div>
        <p>TODO: /connections/list</p>
        { this.state.items.map((item) => this.renderConnection(item)) }
      </div>
    );
  }
}
