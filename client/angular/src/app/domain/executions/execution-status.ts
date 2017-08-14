import { TestCaseStatus } from "./testcase-status";

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
    let failures = [];
    if (data.fail) {
      for (let fail of data.fail) {
        failures.push(TestCaseStatus.create(fail));
      }
    }

    let passes = [];
    if (data.pass) {
      for (let pass of data.pass) {
        passes.push(TestCaseStatus.create(pass));
      }
    }

    let skips = [];
    if (data.skip) {
      for (let skip of data.skip) {
        skips.push(TestCaseStatus.create(skip));
      }
    }


    let notRuns = [];
    if (data.notRun) {
      for (let notRun of data.notRun) {
        notRuns.push(TestCaseStatus.create(notRun));
      }
    }

    return new ExecutionStatus(data.id, data.name, data.project_id, data.project_name, data.closed,
      failures, passes, skips, notRuns);
  }
}
