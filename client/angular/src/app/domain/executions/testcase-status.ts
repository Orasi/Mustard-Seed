export class TestCaseStatus {

  constructor(
    public id: number,
    public validationId: string,
    public name: string,
    public path: string
  ) {  }

  public static create(data: any): TestCaseStatus {
    return new TestCaseStatus(data.id, data.validationId, data.name, data.path);
  }
}
