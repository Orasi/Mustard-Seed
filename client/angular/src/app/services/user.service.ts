import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable, BehaviorSubject } from 'rxjs';
import 'rxjs/add/operator/map'

import { User } from '../domain/user';
import * as Globals from '../globals';


@Injectable()
export class UserService {
  private usersUrl: string = Globals.mustardUrl + '/users';

  private usersSource = new BehaviorSubject<any>([]);
  usersChange = this.usersSource.asObservable();

  private errorSource = new BehaviorSubject<any>({});
  errorChange = this.errorSource.asObservable();

  users: User[] = [];

  constructor(private http: Http) { }

  isAdmin(): boolean {
    if (localStorage.getItem('currentUser')) {
      return JSON.parse(localStorage.getItem('currentUser')).admin;
    }
    return false;
  }

  createUser(user: User | Object): Observable<User> {
    return this.http.post(this.usersUrl, user, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return User.create(data.user);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
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

  getUsers() {
    if (this.users.length > 0) {
      this.usersSource.next(this.users);
    }
    else {
      this.http.get(this.usersUrl, Globals.getTokenHeaders())
        .map(function(res) {
          let data = res.json();

          if (data) {
            let users = [];
            for (let user of data.users) {
              users.push(User.create(user));
            }
            return users;
          }
        })
        .catch((error:any) => Observable.throw(error || 'Server error'))
        .subscribe(result => {
          this.usersSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
    }
  }
}
