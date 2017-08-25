import {TestCase} from "./testcases/testcase";
export class Keyword {

  constructor(
    public id: number,
    public keyword: string,
    public projectId: number,
    public testcaseCount: number,
    public testcases: Array<TestCase>
  ) {  }

  public static create(data: any): Keyword {
    let testcases = [];
    if (data.testcases) {
      for (let testcase of data.testcases) {
        testcases.push(testcase);
      }
    }

    if (data.id == null) {
      return new Keyword(null, null, null, 0, []);
    }

    return new Keyword(data.id, data.keyword, data.project_id, data.testcase_count, []);
  }
}
