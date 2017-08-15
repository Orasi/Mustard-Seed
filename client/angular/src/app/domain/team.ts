import { User } from "./user";
import { Project } from "./project";


export class Team {


  constructor(
    public id: number,
    public name: string,
    public description: string,
    public projects: Array<Project>,
    public users: Array<User>
  ) {  }

  public static create(data: any): Team {
    let projects = [];
    if (data.projects) {
      for (let project of data.projects) {
        projects.push(Project.create(project));
      }
    }

    let users = [];
    if (data.users) {
      for (let user of data.users) {
        users.push(User.create(user));
      }
    }

    return new Team(data.id, data.name, data.description, projects, users);
  }
}
