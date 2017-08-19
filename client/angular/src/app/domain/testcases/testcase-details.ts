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
    let reproductionSteps = [];
    if (data.reproduction_steps) {
      for (let step of data.reproduction_steps) {
        reproductionSteps.push(ReproductionStep.create(step));
      }
    }

    let keywords = [];
    if (data.keywords) {
      for (let keyword of data.keywords) {
        keywords.push(new Keyword(keyword.id, keyword.keyword, null, null, []));
      }
    }

    return new TestCaseDetails(
      data.id,
      data.testcase_name,
      data.testcase_id,
      data.project_id,
      data.outdated,
      data.version,
      reproductionSteps,
      keywords);
  }
}
