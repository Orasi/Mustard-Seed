import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable, BehaviorSubject } from 'rxjs';
import * as Globals from '../globals';
import { Team } from "../domain/team";


@Injectable()
export class TeamService {
  private teamsUrl: string = Globals.mustardUrl + '/teams';

  private teamsSource = new BehaviorSubject<any>([]);
  teamsChange = this.teamsSource.asObservable();

  private teamSource = new BehaviorSubject<any>([]);
  teamChange = this.teamSource.asObservable();

  private errorSource = new BehaviorSubject<any>({});
  errorChange = this.errorSource.asObservable();

  teams: Team[] = [];


  constructor(private http: Http) { }

  getTeams() {
    if (this.teams.length > 0) {
      this.teamsSource.next(this.teams);
    }
    else {
      this.http.get(this.teamsUrl, Globals.getTokenHeaders())
        .map(function (res) {
          let data = res.json();

          if (data) {
            let teams = [];

            for (let team of data.teams) {
              teams.push(Team.create(team));
            }
            return teams
          }
        })
        .catch((error: any) => Observable.throw(error.json().error || 'Server error'))
        .subscribe(result => {
            this.teams = result;
            this.sortTeamsAlphabetically();
            this.teamsSource.next(this.teams);
        },
        error => {
            this.errorSource.next(error);
        });
    }
  }

  getTeam(id: number) {
    let teamUrl = this.teamsUrl + "/" + id;

    this.http.get(teamUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'))
      .subscribe(result => {
        this.sortTeamsAlphabetically();
        this.teamSource.next(result);
      },
      error => {
        this.errorSource.next(error);
      });
  }

  createTeam(name: string, description: string) {

    let body = JSON.stringify({
      "team": { "name": name, "description": description }
    });

    this.http.post(this.teamsUrl, body, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
        this.teams.push(result);
        this.sortTeamsAlphabetically();
        this.teamsSource.next(this.teams);
      },
      error => {
        this.errorSource.next(error);
      });
  }

  editTeam(id: number, name: string, description: string) {
    let teamUrl = this.teamsUrl + "/" + id;

    let body = JSON.stringify({
      "team": { "name": name, "description": description }
    });

    for (let team of this.teams) {
      if (team.id == id) {
        team.name = name;
        team.description = description;
        this.sortTeamsAlphabetically();
        this.teamsSource.next(this.teams);
      }
    }

    this.http.post(teamUrl, body, Globals.getTokenHeaders())
      .map(function(res) {
        return !!res.json();
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => { },
        error => {
          this.errorSource.next(error);
        });
  }

  deleteTeam(id: number) {
    let teamUrl = this.teamsUrl + "/" + id;

    for (var team of this.teams) {
      if (team.id == id) {
        let index = this.teams.indexOf(team, 0);

        if (index > -1) {
          this.teams.splice(index, 1);
        }
        this.sortTeamsAlphabetically();
        this.teamSource.next(this.teams);
      }
    }

    this.http.delete(teamUrl, Globals.getTokenHeaders())
      .map(function(res) {
        return !!res.json();
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => { },
        error => {
          this.errorSource.next(error);
        });
  }

  addUser(teamId: string, userId: string) {
    let addUserUrl = this.teamsUrl + "/" + teamId + "/user/" + userId;

    this.http.post(addUserUrl, null, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          for (var team of this.teams) {
            if (team.id == result.id) {
              let index = this.teams.indexOf(team, 0);

              if (index > -1) {
                this.teams.splice(index, 1);
              }
              this.teams.push(result);
            }
          }
          this.sortTeamsAlphabetically();
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }

  deleteUser(teamId: string, userId: string) {
    let deleteUserUrl = this.teamsUrl + "/" + teamId + "/user/" + userId;

    this.http.delete(deleteUserUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          for (var team of this.teams) {
            if (team.id == result.id) {
              let index = this.teams.indexOf(team, 0);

              if (index > -1) {
                this.teams.splice(index, 1);
              }
              this.teams.push(result);
            }
          }
          this.sortTeamsAlphabetically();
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }

  addProject(teamId: string, projectId: string) {
    let addProjectUrl = this.teamsUrl + "/" + teamId + "/project/" + projectId;

    this.http.post(addProjectUrl, null, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          for (var team of this.teams) {
            if (team.id == result.id) {
              let index = this.teams.indexOf(team, 0);

              if (index > -1) {
                this.teams.splice(index, 1);
              }
              this.teams.push(result);
            }
          }
          this.sortTeamsAlphabetically();
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }

  deleteProject(teamId: string, projectId: string) {
    let deleteProjectUrl = this.teamsUrl + "/" + teamId + "/project/" + projectId;

    this.http.delete(deleteProjectUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          for (var team of this.teams) {
            if (team.id == result.id) {
              let index = this.teams.indexOf(team, 0);
              if (index > -1) {
                this.teams.splice(index, 1);
              }
              this.teams.push(result);
            }
          }
          this.sortTeamsAlphabetically();
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }



  sortTeamsAlphabetically() {
    this.teams.sort(function(a, b){
      var nameA = a.name.toLowerCase(), nameB = b.name.toLowerCase();
      if (nameA < nameB) //sort string ascending
        return -1;
      if (nameA > nameB)
        return 1;
      return 0; //default return value (no sorting)
    });
  }
}
