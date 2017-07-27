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
    if (data.projects) {
      var projects = [];
      for (var project of data.projects) {
        projects.push(Project.create(project));
      }
    }

    if (data.users) {
      var users = [];
      for (var user of users) {
        users.push(User.create(user));
      }
    }

    return new Team(data.id, data.name, data.description, projects, users);
  }
}
