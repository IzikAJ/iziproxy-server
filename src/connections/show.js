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
      count: 0,
    };
    this.uuid = props.match.params.id;

    User.hook(this, user => {
      this.setState({
        user,
        loading: false,
      });
    });
  }

  askForMore(checkpoint) {
    User.instance.sock_input.next(JSON.stringify({
      type: 'before',
      uuid: this.uuid,
      before: checkpoint && checkpoint.uuid,
      kind: 4,
    }));
  }

  componentDidMount() {
    if (this.uuid) {
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
            }),
          });
        } else if (message.type === 'array') {
          const items = message.items.map(item => {
            return {
              type: 'blob',
              ...item
            };
          });
          this.setState({
            items: items,
            count: message.count || 0,
          });
        } else if (message.type === 'before') {
          const items = [...this.state.items, ...message.items.map(item => {
            return {
              type: 'blob',
              ...item,
            };
          })];

          this.setState({
            items,
            count: message.count || 0,
          });
        } else {
          this.setState({
            items: [message, ...this.state.items],
            count: this.state.count + 1,
          });
        }
      });
    }
  }

  componentWillUnmount() {
    if (this.uuid) {
      User.instance.unsubscribeClientLog(this.uuid);
      this._sub.unsubscribe();
    }
  }

  renderStatusBadge(item) {
    let badges = ['status-badge'];
    if (item.at === 'sent' || !item.status_code) {
      badges.push('pending');
    } else if (item.status_code >= 100 && item.status_code < 200) {
      // Informational
      badges.push('info');
    } else if (item.status_code >= 200 && item.status_code < 300) {
      // Success
      badges.push('success');
    } else if (item.status_code >= 300 && item.status_code < 400) {
      // Redirection
      badges.push('redirect');

      if (item.status_code === 304) {
        // Not Modified
        badges.push('not-modified');
      }
    } else if (item.status_code >= 400 && item.status_code < 500) {
      // Client errors
      badges.push('redirect', 'client-error');
    } else if (item.status_code >= 500 && item.status_code < 600) {
      // Server errors
      badges.push('redirect', 'server-error');
    }
    if (badges.length > 1) {
      return (
        <span className={ badges.join(' ') }></span>
      );
    }
  }

  renderBlob(item) {
    return (
      <div className="request">
        <span className="id">
          { item.id }
        </span>
        <span className="status">
          { item.status_code }
          { this.renderStatusBadge(item) }
        </span>
        <span className="method">
          { item.method }
        </span>
        <span className="fullpath">
          <span className="path">
            { item.path }
          </span>
          {
            item.query
              ? <span className="query">{ item.query }</span>
              : ''
          }
        </span>
      </div>
    );
  }

  renderShowMore({items, count}) {
    if (count === 0) { return }
    if (items.length < count) {
      return (
        <div>
          { items.length } of {count} items are shown
          <button onClick={ () => this.askForMore(items[items.length - 1]) }>
            show more
          </button>
        </div>
      );
    } else {
      // no show more btn
      return (
        <div>
          all {count} items are shown
        </div>
      );
    }
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
      <div key={item.uuid || Math.random().toString(36).slice(2,12)}>
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
        { this.renderShowMore(this.state) }
      </div>
    );
  }
}
