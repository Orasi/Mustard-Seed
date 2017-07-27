import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { TestCaseDetails } from "../domain/testcases/testcase-details";
import * as Globals from '../globals';


@Injectable()
export class TestCaseService {
  private testcasesUrl: string = Globals.mustardUrl + '/testcases';

  constructor(private http: Http) { }

  getTestCaseDetails(id: string): Observable<TestCaseDetails> {
    let testcaseUrl = this.testcasesUrl + "/" + id;

    return this.http.get(testcaseUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return TestCaseDetails.create(data.testcase);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }
}

