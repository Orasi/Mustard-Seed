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
    if (data.testcases) {
      var testcases = [];
      for (var testcase of data.testcases) {
        testcases.push(testcase);
      }
    }

    return new Keyword(data.id, data.keyword, data.projectId, data.testcaseCount, []);
  }
}
