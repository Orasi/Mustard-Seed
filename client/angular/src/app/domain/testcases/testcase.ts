import { Keyword } from "../keyword";


export class TestCase {

  constructor(
    public id: number,
    public name: string,
    public testcaseId: string,
    public version: string,
    public keywords: Array<Keyword>
  ) {  }

  public static create(data: any): TestCase {
    let keywords = [];
    if (data.keywords && data.keywords[0] != null) {
      for (let keyword of data.keywords) {
        keywords.push(new Keyword(keyword.id, keyword.keyword, null, null, []));
      }
    }

    return new TestCase(data.id, data.testcase_name, data.testcase_id, data.version, keywords);
  }
}
