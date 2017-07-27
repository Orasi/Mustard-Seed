import { Result } from './result';


export class RecentResult {


  constructor(
    public id: number,
    public environmentId: number,
    public testCaseId: number,
    public testCaseName: string,
    public testCaseValidationId: string,
    public executionId: number,
    public projectId: number,
    public projectName: string,
    public result: Result
  ) {  }

  public static create(data: any): RecentResult {
    return new RecentResult(data.id, data.environmentId, data.testCaseId, data.testCaseName, data.testCaseValidationId,
      data.executionId, data.projectId, data.projectName, Result.create(data.result));
  }
}
