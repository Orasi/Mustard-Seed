export class User {

  constructor(
    public id: number,
    public username: string,
    public email: string,
    public firstName: string,
    public lastName: string,
    public token: string,
    public admin: boolean,
    public createdAt: Date,
    public updatedAt: Date
  ) {  }

}
