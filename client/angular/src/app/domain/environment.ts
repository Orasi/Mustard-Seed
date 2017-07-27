export class Environment {

  constructor(
    public id: number,
    public uuid: string,
    public projectId: number,
    public name: string,
    public type: string
  ) {  }

  public static create(data: any): Environment {
    return new Environment(data.id, data.uuid, data.projectId, data.name, data.type);
  }
}
