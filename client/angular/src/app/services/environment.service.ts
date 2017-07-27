import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { Environment } from "../domain/environment";
import * as Globals from '../globals';


@Injectable()
export class EnvironmentService {
  private environmentsUrl: string = Globals.mustardUrl + '/environments';

  constructor(private http: Http) { }

  getEnvironment(id: string): Observable<Environment> {
    let environmentUrl = this.environmentsUrl + "/" + id;

    return this.http.get(environmentUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Environment.create(data.environment);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  deleteEnvironment(id: string) {
    let environmentUrl = this.environmentsUrl + "/" + id;

    this.http.delete(environmentUrl, Globals.getTokenHeaders())
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }
}
