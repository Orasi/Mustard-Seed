export class Result {


  constructor(
    public status: string,
    public resultType: string,
    public comment: string,
    public stacktrace: string,
    public link: string
  ) {  }

  public static create(data: any): Result {
    return new Result(data.status, data.resultType, data.comment, data.stacktrace, data.link);
  }
}
