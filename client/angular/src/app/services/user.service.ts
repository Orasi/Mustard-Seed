import { Injectable } from '@angular/core';
import { Http, Headers, Response, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'
import { User } from '../domain/user';
import * as Globals from '../globals';


@Injectable()
export class UserService {
  private createUserUrl: string = Globals.mustardUrl + '/users';
  private passwordResetEmailUrl: string = Globals.mustardUrl + '/users/forgot-password';

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

    return this.http.post(this.createUserUrl, user, options)
      .map(function(res){
        let data = res.json();

        if (data) {
          // TODO update per conversation with matt about admins only being allowed to create new users
          return true;
        } else {
          return false;
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }


  sendPasswordResetEmail(email: string) {
    let redirectionUrl = "http://localhost:4200/resetPassword";

    let body = JSON.stringify({ "user": { email: email }, "redirect-to": redirectionUrl });
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    this.http.post(this.passwordResetEmailUrl, body, options);
  }
}
