import { Component, Input, OnInit } from '@angular/core';
import {Router, ActivatedRoute} from '@angular/router';
import { ProjectService } from "../../../services/project.service";
import { AuthenticationService } from "../../../services/authentication.service";
import { Project } from "../../../domain/project";
import { ModalService } from "../../../services/modal.service";
import {TeamService} from "../../../services/team.service";


@Component({
  selector: 'app-team-project-list',
  templateUrl: './team-project-list.component.html',
  providers: [ ModalService ]
})
export class TeamProjectListComponent implements OnInit {

  @Input() projects: Project[] = [];

  private teamId: string;


  constructor(private projectService: ProjectService,
              private teamService: TeamService,
              private router: Router,
              private route: ActivatedRoute,
              public modalService: ModalService) {
    this.teamId = this.route.snapshot.params['id'];
  }

  ngOnInit() {
    this.projectService.projectsChange.subscribe(result => {
      this.projects = result;
    });
  }

  deleteProject($event, index) {
    let projectId = $event.target.id;
    this.projects.splice(index, 1);
    this.teamService.deleteProject(this.teamId, projectId);
  }

  addProject(project: Project) {
    this.projects.push(project);
  }
}
