import { SubjectStore } from '../_utils/subject_store';
import cookie from 'cocookie';
import { Api } from '../_utils/api';

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

    Api.servers.list().then(data => {
      console.log('SERVERS', data);
    }).catch(err => {
      console.log('SERVERS FAILED');
    });

    Api.profile.tokens.list().then(data => {
      console.log('TOKENS', data);
    }).catch(err => {
      console.log('TOKENS FAILED');
    });
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
