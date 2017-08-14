import { Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ProjectService } from "../../../services/project.service";
import { AuthenticationService } from "../../../services/authentication.service";
import { Project } from "../../../domain/project";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-project-list',
  templateUrl: './project-list.component.html',
  providers: [ ModalService ]
})
export class ProjectListComponent implements OnInit {

  @Input() projects: Project[] = [];
  userName: String;

  constructor(private projectService: ProjectService,
              private router: Router,
              public modalService: ModalService) {
  }

  ngOnInit() {
    if (localStorage.getItem('currentUser')) {
      this.userName = JSON.parse(localStorage.getItem('currentUser')).name;
    } else {
      AuthenticationService.logout();
      this.router.navigate(['/login']);
    }

    this.projectService.projectsChange.subscribe(result => {
      this.projects = result;
    });
  }

  addProject(project: Project) {
    this.projects.push(project);
  }

  deleteProject($event: any, index: number) {
    let projectId = $event.target.id;
    this.projects.splice(index, 1);
    this.projectService.deleteProject(projectId);
  }

  toProject(id: number) {
    // TODO add route to project
    alert("Add route to project");
  }
}
