import { Component, Input, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { ProjectService } from "../../../services/project.service";
import { Project } from "../../../domain/project";
import { ModalService } from "../../../services/modal.service";
import { TeamService } from "../../../services/team.service";


@Component({
  selector: 'app-team-project-list',
  templateUrl: './team-project-list.component.html',
  providers: [ ModalService ]
})
export class TeamProjectListComponent implements OnInit {

  @Input() projects: Project[] = [];
  

  constructor(private projectService: ProjectService,
              private teamService: TeamService,
              private router: Router,
              private route: ActivatedRoute,
              public modalService: ModalService) { }

  ngOnInit() {
    this.teamService.teamChange.subscribe(result => {
      this.projects = result.projects;
    });
  }

  deleteProject($event, index) {
    let teamId = this.route.snapshot.params['id'];
    let projectId = $event.target.id;
    this.teamService.deleteProject(teamId, projectId);
  }

  addProject(project: Project) {
    this.projects.push(project);
  }
}
