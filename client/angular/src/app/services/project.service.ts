import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable, BehaviorSubject } from 'rxjs';
import 'rxjs/add/operator/map'

import { Project } from "../domain/project";
import * as Globals from '../globals';


@Injectable()
export class ProjectService {
  private projectsUrl: string = Globals.mustardUrl + '/projects';

  private projectsSource = new BehaviorSubject<any>([]);
  projectsChange = this.projectsSource.asObservable();

  private projectSource = new BehaviorSubject<any>({});
  projectChange = this.projectSource.asObservable();

  private errorSource = new BehaviorSubject<any>({});
  errorChange = this.errorSource.asObservable();

  private projects: Project[] = [];


  constructor(private http: Http) { }

  getProjects() {
    if (this.projects.length > 0) {
      this.projectsSource.next(this.projects);
    }
    else {
      this.http.get(this.projectsUrl, Globals.getTokenHeaders())
        .map(function (res) {
          let data = res.json();

          if (data) {
            this.projects = [];

            for (let project of data.projects) {
              this.projects.push(Project.create(project));
            }
            return this.projects;
          }
        })
        .catch((error: any) => Observable.throw(error || 'Server error'))
        .subscribe(
          result => {
            this.projects = result;
            this.projectsSource.next(this.projects);
          },
          error => {
            this.errorSource.next(true);
          });
    }
  }

  editProject(id: number, name: string) {
    let projectDeleteUrl = this.projectsUrl + "/" + id;

    for (var project of this.projects) {
      if (project.id == id) {
        project.name = name;
        this.projectSource.next(project);
      }
    }

    this.http.put(projectDeleteUrl, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          return Project.create(data.project);
        }
      })
      .catch((error: any) => Observable.throw(error || 'Server error'))
      .subscribe(
        result => {
          this.projectSource.next(result);
        },
        error => {
          this.errorSource.next(true);
        });
  }

  createProject(name: string) {
    let body = JSON.stringify({ "project": { "name": name }});

    this.http.post(this.projectsUrl, body, Globals.getTokenHeaders())
      .map(function(res){
        let data = res.json();

        if (data) {
          return Project.create(data.project);
        }
      })
      .subscribe(
        result => {
          this.projects.push(result);
          this.projectsSource.next(this.projects);
        },
        error => {
          this.errorSource.next(true);
        });
  }

  deleteProject(id: number) {
    let projectDeleteUrl = this.projectsUrl + "/" + id;

    for (var project of this.projects) {
      if (project.id == id) {
        let index = this.projects.indexOf(project, 0);

        if (index > -1) {
          this.projects.splice(index, 1);
        }
        this.projectsSource.next(this.projects);
      }
    }

    this.http.delete(projectDeleteUrl, Globals.getTokenHeaders())
      .map(function(res){
        return !!res.json();
      })
      .subscribe(
        result => { },
        error => {
          this.errorSource.next(true);
        });
  }

  getProject(id: number) {
    let projectUrl = this.projectsUrl + "/" + id;

    this.http.get(projectUrl, Globals.getTokenHeaders())
      .map(function (res) {
        let data = res.json();

        if (data) {
          return Project.create(data.project);
        }
      })
      .catch((error: any) => Observable.throw(error || 'Server error'))
      .subscribe(
        result => {
          this.projectSource.next(result);
        },
        error => {
          this.errorSource.next(true);
        });
  }
}
