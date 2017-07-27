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
    if (data.keywords) {
      var keywords = [];
      for (var keyword of data.keywords) {
        keywords.push(new Keyword(keyword.id, keyword.keyword, null, null, []));
      }
    }

    return new TestCase(data.id, data.name, data.testcaseId, data.version, keywords);
  }
}
