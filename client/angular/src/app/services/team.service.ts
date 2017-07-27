import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import * as Globals from '../globals';
import { Team } from "../domain/team";


@Injectable()
export class TeamService {
  private teamsUrl: string = Globals.mustardUrl + '/teams';

  constructor(private http: Http) { }

  getTeams(): Observable< Array<Team> > {
    return this.http.get(this.teamsUrl, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          var teams = [];

          for (var team of data.teams) {
            teams.push(Team.create(team));
          }
          return teams
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  getTeam(id: number): Observable<Team> {
    let teamUrl = this.teamsUrl + "/" + id;

    return this.http.get(teamUrl, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }

  createTeam(name: string, description: string): Observable<Team> {

    let body = JSON.stringify({
      "team": { "name": name, "description": description }
    });

    return this.http.post(this.teamsUrl, body, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          return Team.create(data.team);
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }
}
