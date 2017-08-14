import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { Execution } from "../domain/executions/execution";
import { ExecutionStatus } from "../domain/executions/execution-status";
import { EnvironmentSummary } from "../domain/executions/environment-summary";
import { ExecutionSummary } from "../domain/executions/execution-summary";
import * as Globals from '../globals';


@Injectable()
export class ExecutionService {
  private executionsUrl: string = Globals.mustardUrl + '/executions';

  constructor(private http: Http) { }

  getExecution(id: string): Observable<Execution> {
    let executionUrl = this.executionsUrl + "/" + id;

    return this.http.get(executionUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Execution.create(data.execution);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  closeExecution(projectKey: string, name: string): Observable<Execution> {
    let executionUrl = this.executionsUrl + "/close";

    let body = JSON.stringify({
      "project_key": projectKey,
      "name": name
    });

    return this.http.post(executionUrl, body, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Execution.create(data.execution);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  deleteExecution(id: string) {
    let executionUrl = this.executionsUrl + "/" + id;

    return this.http.delete(executionUrl, Globals.getTokenHeaders())
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  getTestCaseStatus(id: string): Observable<ExecutionStatus> {
    let testcaseStatusUrl = this.executionsUrl + "/" + id + "/testcase_status";

    return this.http.get(testcaseStatusUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return ExecutionStatus.create(data.execution);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  getTestCaseSummary(id: string): Observable<ExecutionSummary> {
    let testcaseSummaryUrl = this.executionsUrl + "/" + id + "/testcase_summary";

    return this.http.get(testcaseSummaryUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return ExecutionSummary.create(data.execution);
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  getEnvironmentSummary(id: string): Observable< Array<EnvironmentSummary> > {
    let testcaseSummaryUrl = this.executionsUrl + "/" + id + "/testcase_status";

    return this.http.get(testcaseSummaryUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          let summary = [];
          for (let environment of data.summary) {
            summary.push(EnvironmentSummary.create(environment));
          }
          return summary;
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }
}
