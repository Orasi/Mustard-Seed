import { Injectable } from '@angular/core';
import { Http, Headers, Response, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'
import * as Globals from '../globals';


@Injectable()
export class AuthenticationService {
  private loginUrl: string = Globals.mustardUrl + '/authenticate';
  public token: string;

  constructor(private http: Http) {
    if (localStorage.getItem('currentUser') != null) {
      this.token = JSON.parse(localStorage.getItem('currentUser')).token;
    }
  }

  login(username: string, password: string): Observable<boolean> {
    let user = JSON.stringify({ username: username, password: password });
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http.post(this.loginUrl, user, options)
      .map(function(res){
        let data = res.json();

        if (data) {
          let cookie = JSON.stringify({ username: data.user.username, token: data.user.token, admin: data.user.admin });

          localStorage.setItem('currentUser', cookie);
          return true; // successful login
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  logout(): void {
    this.token = null;
    localStorage.removeItem('currentUser');
  }
}
