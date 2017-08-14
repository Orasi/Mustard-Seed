import { Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ProjectService } from "../../../services/project.service";
import { AuthenticationService } from "../../../services/authentication.service";
import { Project } from "../../../domain/project";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-team-project-list',
  templateUrl: './team-project-list.component.html'
})
export class TeamProjectListComponent implements OnInit {

  @Input() projects: Project[] = [];

  constructor(private projectService: ProjectService,
              private router: Router,
              public modalService: ModalService) {
  }

  ngOnInit() {
    this.projectService.projectsChange.subscribe(result => {
      this.projects = result;
    });
  }

  addProject(project: Project) {
    this.projects.push(project);
  }
}
