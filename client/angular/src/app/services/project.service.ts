import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs';
import 'rxjs/add/operator/map'

import { Project } from "../domain/project";
import * as Globals from '../globals';


@Injectable()
export class ProjectService {
  private projectsUrl: string = Globals.mustardUrl + '/projects';

  constructor(private http: Http) { }

  getProjects(): Observable< Map<string, Project> > {
    return this.http.get(this.projectsUrl, Globals.getTokenHeaders())
      .map(function(res) {
        let data = res.json();

        if (data) {
          let map = new Map();
          for (var project of data.projects) {
            map.set(project.id, Project.create(project));
          }
          return map
        }
      })
      .catch((error:any) => Observable.throw(error || 'Server error'));
  }

  getProject(id: number): Observable<Project> {
    let projectUrl = this.projectsUrl + "/" + id;

    return this.http.get(projectUrl, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          return Project.create(data.project)
        }
      })
      .catch((error:any) => Observable.throw(error.json().error || 'Server error'));
  }
}
