import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions  } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'
import * as Globals from '../globals';


@Injectable()
export class AuthenticationService {
  private loginUrl: string = Globals.mustardUrl + '/authenticate';

  constructor(private http: Http) { }

  login(username: string, password: string): Observable<boolean> {
    let body = JSON.stringify({ username: username, password: password });
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http.post(this.loginUrl, body, options)
      .map(function(res){
        let data = res.json();

        if (data) {
          let fullName = data.user.first_name + " " +  data.user.last_name;
          let cookie = JSON.stringify({
            username: data.user.username, name: fullName, token: data.user.token, admin: data.user.admin
          });

          localStorage.setItem('currentUser', cookie);
          return true; // successful login
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  static logout(): void {
    localStorage.removeItem('currentUser');
  }
}
