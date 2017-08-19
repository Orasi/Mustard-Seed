export class ReproductionStep {

  constructor(
    public stepNumber: number,
    public action: string,
    public result: string,
  ) {  }

  public static create(data: any): ReproductionStep {
    return new ReproductionStep(data.step_number, data.action, data.result);
  }
}
