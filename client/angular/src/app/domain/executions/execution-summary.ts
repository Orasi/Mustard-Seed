export class ExecutionSummary {

  constructor(
    public id: number,
    public name: string,
    public validationId: string,
    public passCount: number,
    public failCount: number,
    public skipCount: number,
    public updatedAt: string
  ) {  }

  public static create(data: any): ExecutionSummary {
    return new ExecutionSummary(
      data.id, data.name, data.validation_id, data.pass_count, data.fail_count, data.skip_count, data.updated_at);
  }
}
