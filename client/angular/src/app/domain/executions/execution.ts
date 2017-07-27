export class Execution {

  constructor(
    public id: number,
    public name: string,
    public closed: boolean
  ) {  }

  public static create(data: any): Execution {
    return new Execution(data.id, data.name, data.closed);
  }
}
