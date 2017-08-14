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
        this.teamsSource.next(this.teams);
      },
      error => {
        this.errorSource.next(error);
      });
  }

  addUser(teamId: string, userId: string) {
    let addUserUrl = this.teamsUrl + "/" + teamId + "/user/" + userId;

    this.http.post(addUserUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }

  addProject(teamId: string, projectId: string) {
    let addProjectUrl = this.teamsUrl + "/" + teamId + "/projects/" + projectId;

    this.http.post(addProjectUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json() || 'Server error'))
      .subscribe(result => {
          this.teamSource.next(result);
        },
        error => {
          this.errorSource.next(error);
        });
  }
}
