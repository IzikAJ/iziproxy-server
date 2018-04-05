import { ReplaySubject } from 'rxjs/ReplaySubject';

import 'rxjs/add/operator/share';

const INSTANCE_STORE_KEY = '___subject_store___';

export class SubjectStore {
  _findOrCreate(key) {
    if (key in this._subjects) {
      return this._subjects[key];
    }
    return this._subjects[key] = new ReplaySubject(1);
  }

  sync(key) {
    return this._findOrCreate(key);
  }

  set(key, value) {
    return this._findOrCreate(key).next(value);
  }

  static sync(key) {
    return this.instance.sync(key);
  }

  static set(key, value) {
    return this.instance.set(key, value);
  }

  static hook(context, key, callback) {
    const cdm = context['componentDidMount'];
    const cwu = context['componentWillUnmount'];
    const _this = this;
    let _sub;
    context.componentDidMount = function() {
      if (cdm) { cdm.call(this); }
      _sub = _this.sync(key).subscribe(val => {
        callback.call(this, val);
      });
    };
    context.componentWillUnmount = function() {
      if (_sub) {
        _sub.unsubscribe();
        _sub = undefined;
      }
      if (cwu) { cwu.call(this); }
    };
  }

  static get instance() {
    if (window && INSTANCE_STORE_KEY in window) {
      return window[INSTANCE_STORE_KEY];
    }
    const store = new SubjectStore();
    return window[INSTANCE_STORE_KEY] = store;
  }

  constructor() {
    this._subjects = {};
  }
}

export default SubjectStore;
