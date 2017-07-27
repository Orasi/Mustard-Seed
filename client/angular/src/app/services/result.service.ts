import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';

import { RecentResult } from '../domain/results/recent-result';
import * as Globals from '../globals';


@Injectable()
export class ResultService {
  private resultsUrl: string = Globals.mustardUrl + '/results';

  constructor(private http: Http) { }

  getRecentResults(count, executionId): Observable< Array<RecentResult> > {
    let recentResultsUrl = this.getRecentResultsUrl(count, executionId);

    return this.http.get(recentResultsUrl, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          var results = [];
          for (var result of data.results) {
            results.push(RecentResult.create(result));
          }
          return results;
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  private getRecentResultsUrl(count, executionId): string {
    let recentResultsUrl = Globals.mustardUrl + '/recent-results';

    if (count && executionId) {
      recentResultsUrl += '?count=' + count + "&execution_id=" + executionId;
    }
    else if (count) {
      recentResultsUrl += '?count=' + count;
    }
    else if (executionId) {
      recentResultsUrl += '?execution_id=' + executionId;
    }
    return recentResultsUrl;
  }
}
