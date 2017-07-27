export class User {

  constructor(
    public id: number,
    public username: string,
    public email: string,
    public firstName: string,
    public lastName: string,
    public token: string,
    public admin: boolean
  ) {  }

  public static create(data: any): User {
    return new User(data.id, data.username, data.email, data.firstName, data.lastName, data.token, data.admin);
  }
}
