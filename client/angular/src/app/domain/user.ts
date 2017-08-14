export class User {

  constructor(
    public id: number,
    public username: string,
    public email: string,
    public firstName: string,
    public lastName: string,
    public company: string,
    public token: string,
    public admin: boolean
  ) {  }

  public static create(data: any): User {
    return new User(data.id, data.username, data.email, data.first_name, data.last_name, data.company, data.token, data.admin);
  }
}
