import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { Keyword } from '../domain/keyword';
import * as Globals from '../globals';


@Injectable()
export class KeywordService {
  private keywordsUrl: string = Globals.mustardUrl + '/keywords';

  constructor(private http: Http) { }

  getKeyword(id: string): Observable<Keyword> {
    let keywordUrl = this.keywordsUrl + "/" + id;

    return this.http.get(keywordUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Keyword.create(data.keyword);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }
}
