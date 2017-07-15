import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions } from '@angular/http';

import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/map';

import * as Globals from '../globals';
import { User } from '../domain/user';


@Injectable()
export class LoginService {

  private loginUrl: string = Globals.mustardUrl + '/authenticate';

  constructor(private http: Http) { }

  login (username: string, password: string): Observable<User> {
    let user = { username, password };
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http.post(this.loginUrl, user, options)
      .map(function(res){
          let data = res.json();
          console.log(data);
          this.user = new User(data.id, data.username, data.email, data.first_name, data.last_name, data.token, data.admin);
          return this.user;
      })
      .catch(this.handleError);
  }


  private handleError (error: Response | any) {
    let errMsg: string;
    if (error instanceof Response) {
      const body = error.json() || '';
      const err = body.error || JSON.stringify(body);
      errMsg = `${error.status} - ${error.statusText || ''} ${err}`;
    } else {
      errMsg = error.message ? error.message : error.toString();
    }
    console.error(errMsg);
    return Observable.throw(errMsg);
  }
}
