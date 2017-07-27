import { Keyword } from "../keyword";
import { ReproductionStep } from "./reproduction-step";


export class TestCaseDetails {

  constructor(
    public id: number,
    public name: string,
    public testcaseId: string,
    public projectId: number,
    public outdated: boolean,
    public version: string,
    public reproductionSteps: Array<ReproductionStep>,
    public keywords: Array<Keyword>
  ) {  }

  public static create(data: any): TestCaseDetails {
    if (data.reproductionSteps) {
      var reproductionSteps = [];
      for (var step of data.reproductionSteps) {
        reproductionSteps.push(ReproductionStep.create(step));
      }
    }

    if (data.keywords) {
      var keywords = [];
      for (var keyword of data.keywords) {
        keywords.push(new Keyword(keyword.id, keyword.keyword, null, null, []));
      }
    }

    return new TestCaseDetails(data.id, data.name, data.testcaseId, data.projectId, data.outdated, data.version,
      reproductionSteps, keywords);
  }
}
