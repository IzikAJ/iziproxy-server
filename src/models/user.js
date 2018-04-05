import axios from 'axios';
import { SubjectStore } from '../utils/subject_store';
import cookie from 'cocookie';

export class User {
  set token(token) {
    console.log('User.token', token)
    this._token = token;

    cookie('_user_token').set(token, {
      maxAge: 60 * 60 * 24 * 30 // 30 days to die
    });
    this.loadProfile();

    return token;
  }

  static get instance() {
    if ('_current_user' in window) {
      return window['_current_user'];
    }
    const user = new User();
    return window['_current_user'] = user;
  }

  static get active() {
    return this.instance._subject;
  }

  loadProfile() {
    if (this._loading) { return; }
    this._loading = true;
    axios.get('/api/profile.json').then(data => {
      console.log('RELOAD PROFILE', data);
      this._subject.next({
        token: this._token,
        ...data
      });
      this._loading = false;
    }).catch(err => {
      this._loading = false;
    });
  }

  static hook(context, callback) {
    return SubjectStore.hook(context, '__current_user__', callback);
  }

  constructor() {
    console.log('INIT USER!');
    // this._subject = new ReplaySubject(1);
    this._subject = SubjectStore.sync('__current_user__');
    this._token = cookie('_user_token').get();
    this.loadProfile();
  }
}
