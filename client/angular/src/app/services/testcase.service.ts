import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import {Observable, BehaviorSubject} from 'rxjs';
import 'rxjs/add/operator/map'

import { TestCaseDetails } from "../domain/testcases/testcase-details";
import * as Globals from '../globals';


@Injectable()
export class TestCaseService {
  private testcasesUrl: string = Globals.mustardUrl + '/testcases';

  private testcasesSource = new BehaviorSubject<any>([]);
  testcasesChange = this.testcasesSource.asObservable();

  private testcaseSource = new BehaviorSubject<any>([]);
  testcaseChange = this.testcaseSource.asObservable();

  private errorSource = new BehaviorSubject<any>({});
  errorChange = this.errorSource.asObservable();


  constructor(private http: Http) { }

  getTestCaseDetails(id: string) {
    let testcaseUrl = this.testcasesUrl + "/" + id;

    this.http.get(testcaseUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return TestCaseDetails.create(data.testcase);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'))
      .subscribe(result => {
        this.testcaseSource.next(result);
      },
      error => {
        console.log(error);
        this.errorSource.next(error);
      });
  }

  importTestcases(id: string, jsonString: string) {
    let importUrl = Globals.mustardUrl + "/projects/" + id + "/import";

    let json = { update: true, json: jsonString };

    this.http.post(importUrl, JSON.stringify(json), Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return !!res.json();
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'))
      .subscribe(result => { },
      error => {
        this.errorSource.next(error);
      });
  }
}

