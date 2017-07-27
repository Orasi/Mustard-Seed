import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { User } from '../domain/user';
import * as Globals from '../globals';


@Injectable()
export class UserService {
  private usersUrl: string = Globals.mustardUrl + '/users';

  constructor(private http: Http) { }

  isAdmin(): boolean {
    if (localStorage.getItem('currentUser')) {
      return JSON.parse(localStorage.getItem('currentUser')).admin;
    }
    return false;
  }

  create(user: User): Observable<boolean> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http.post(this.usersUrl, user, options)
      .map(function(res){
        return !!res.json();
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  sendPasswordResetEmail(email: string) {
    let passwordResetEmailUrl = Globals.mustardUrl + '/users/forgot-password';
    let redirectionUrl = "http://localhost:4200/resetPassword";

    let body = JSON.stringify({ "user": { email: email }, "redirect-to": redirectionUrl });
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    this.http.post(passwordResetEmailUrl, body, options);
  }

  isTokenValid(): Observable<boolean> {
    if (localStorage.getItem('currentUser')) {
      let tokenUrl = this.usersUrl + "/token/valid";

      return this.http.get(tokenUrl, Globals.getTokenHeaders())
        .map(res => {
            let data = res.json();

            if (data) {
              return data.token === "Valid";
            }
            return false;
          })
        .catch(err => { return Observable.of(false); });
    }
    else {
      return Observable.of(false);
    }
  }
}
