import { Component, OnInit } from '@angular/core';
import { ProjectService } from "../../services/project.service";
import { ExecutionService } from "../../services/execution.service";
import { TeamService } from "../../services/team.service";
import { Project } from "../../domain/project";
import { ExecutionStatus } from "../../domain/executions/execution-status";
import { Team } from "../../domain/team";
import { Router } from "@angular/router";
import * as Globals from '../../globals';


@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html'
})
export class DashboardComponent implements OnInit {

  projects: Project[] = [];
  teams: Team[] = [];
  executionStatus: ExecutionStatus;

  constructor(private projectService: ProjectService,
              private teamService: TeamService,
              private executionService: ExecutionService,
              private router : Router) {

    this.projectService.getProjects();
    this.teamService.getTeams();
  }

  ngOnInit() {
    this.projectService.projectsChange.subscribe(result => {
      if (!Globals.isEmptyObject(result)) {
        this.projects = result;
      }
    });

    // this.executionService.getTestCaseStatus(String(this.projects[0].id)).subscribe(result => {
    //   this.executionStatus = result;
    // });

    this.teamService.teamsChange.subscribe(result => {
      this.teams = result;
    });
  }

  getData() {
    this.projectService.getProjects();
  }
}
