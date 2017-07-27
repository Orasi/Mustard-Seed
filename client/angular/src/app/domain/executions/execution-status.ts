import {TestCaseStatus} from "./testcase-status";

export class ExecutionStatus {

  constructor(
    public id: number,
    public name: string,
    public projectId: number,
    public projectName: string,
    public closed: boolean,
    public fails: Array<TestCaseStatus>,
    public passes: Array<TestCaseStatus>,
    public skips: Array<TestCaseStatus>,
    public notRuns: Array<TestCaseStatus>
  ) {  }

  public static create(data: any): ExecutionStatus {
    if (data.fail) {
      var failures = [];
      for (var fail of data.fail) {
        failures.push(TestCaseStatus.create(fail));
      }
    }

    if (data.pass) {
      var passes = [];
      for (var pass of data.pass) {
        passes.push(TestCaseStatus.create(pass));
      }
    }

    if (data.skip) {
      var skips = [];
      for (var skip of data.skip) {
        skips.push(TestCaseStatus.create(skip));
      }
    }

    if (data.notRun) {
      var notRuns = [];
      for (var notRun of data.notRun) {
        notRuns.push(TestCaseStatus.create(notRun));
      }
    }

    return new ExecutionStatus(data.id, data.name, data.projectId, data.projectName, data.closed,
      failures, passes, skips, notRuns);
  }
}
