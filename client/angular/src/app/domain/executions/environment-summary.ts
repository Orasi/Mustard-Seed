export class EnvironmentSummary {

  constructor(
    public id: number,
    public uuid: string,
    public displayName: string,
    public type: string,
    public passCount: number,
    public failCount: number,
    public skipCount: number
  ) {  }

  public static create(data: any): EnvironmentSummary {
    return new EnvironmentSummary(data.id, data.uuid, data.displayName, data.type,
      data.passCount, data.failCount, data.skipCount);
  }
}

