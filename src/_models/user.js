import { SubjectStore } from '../_utils/subject_store';
import cookie from 'cocookie';
import { Api } from '../_utils/api';

import { QueueingSubject } from 'queueing-subject';
import websocketConnect from 'rxjs-websockets';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/delay';
import 'rxjs/add/operator/retryWhen';
import 'rxjs/add/operator/share';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/filter';

const USER_DATA_STORE_KEY = '__current_user__';
const COOKIE_STORE_KEY = '_user_token';

export class User {
  set token(token) {
    console.log('User.token', token)
    this._token = token;

    cookie(COOKIE_STORE_KEY).set(token, {
      maxAge: 60 * 60 * 24 * 30 // 30 days to die
    });
    this.loadProfile();

    return token;
  }

  static get instance() {
    if (this.current_user) {
      return this.current_user;
    }
    return this.current_user = new User();
  }

  static get active() {
    return this.instance._subject;
  }

  loadProfile() {
    if (this._loading) { return; }
    this._loading = true;
    Api.profile.show().then(data => {
      console.log('RELOAD PROFILE', data);
      this._subject.next({
        token: this._token,
        ...data
      });
      this._loading = false;
    }).catch(err => {
      this._loading = false;
    });

    const input = new QueueingSubject();
    const { messages } = websocketConnect(`ws://lvh.me:8080/socket/${this._token}`, input);

    this.sock_input = input;

    this.sock_pull = messages.map(message => JSON.parse(message))
                             .retryWhen(errors => errors.delay(1000))
                             .do((message) => {

      if (message && message.type === 'welcome') {
        // reconnect to all channels on reset connection
        // _sock_reconnect()
      } else {
        console.log('received message:', message)
      }
    }).share();
  }

  sockOn({filter, onConnect = null}) {
    let pull = this.sock_pull;
    if (typeof(onConnect) === 'function') {
      pull = pull.do(message => {
        if (message && message.type === 'welcome') {
          // need reconnect to all channels on reset connection
          onConnect.call(this);
        }
      });
    }
    return pull.filter(filter);
  }

  subscribeClientLog(uuid) {
    console.log('subscribeClientLog')
    this.sock_input.next(JSON.stringify({
      type: 'join',
      uuid: uuid,
      kind: 4,
    }));
  }

  unsubscribeClientLog(uuid) {
    this.sock_input.next(JSON.stringify({
      type: 'leave',
      uuid: uuid,
      kind: 4,
    }));
  }

  subscribeUserLog() {
    console.log('subscribeUserLog')
    this.sock_input.next(JSON.stringify({
      type: 'join',
      kind: 2,
    }));
  }

  unsubscribeUserLog() {
    this.sock_input.next(JSON.stringify({
      type: 'leave',
      kind: 2,
    }));
  }

  static hook(context, callback) {
    return SubjectStore.hook(context, USER_DATA_STORE_KEY, callback);
  }

  constructor() {
    console.log('INIT USER!');
    // this._subject = new ReplaySubject(1);
    this._subject = SubjectStore.sync(USER_DATA_STORE_KEY);
    this._token = cookie(COOKIE_STORE_KEY).get();
    this.loadProfile();
  }
}
