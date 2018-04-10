import axios from 'axios';

export class ApiConfig {
  constructor() {
    // axios.defaults.baseURL = 'https://api.example.com';
    // axios.defaults.headers.common['Authorization'] = AUTH_TOKEN;
    // axios.defaults.headers.common['Content-Type'] = 'application/json';

    axios.interceptors.response.use((response) => {
      // Do something with response data
      if (response.headers['content-type'] === 'application/json') {
        // console.log('!success!', response.data);
        return response.data;
      }
      return response;
    }, function (error) {
      // Do something with response error
      if (error.response) {
        console.log('Response Error', error.response);
        if (error.response.data) {
          return Promise.reject(error.response.data);
        } else {
          return Promise.reject({
            error: error.response.status_code
          });
        }
      } else if (error.request) {
        console.log('Error no responce', error.request);
        return Promise.reject({error: 'no_responce'});
      } else {
        // Something happened in setting up the request that triggered an Error
        console.log('Response Error', error.message);
      }
      return Promise.reject(error);
    });
  }
}
