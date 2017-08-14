import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from "@angular/router";
import { ProjectService } from '../../services/project.service';
import { TeamService } from '../../services/team.service';
import { UserService } from "../../services/user.service";
import { Team } from "../../domain/team";
import { Project } from "../../domain/project";


@Component({
  selector: 'app-nav-bar',
  templateUrl: './nav-bar.component.html'
})
export class NavBarComponent implements OnInit {

  teams: Team[] = [];
  teamsFlag: boolean = false;

  projects: Project[] = [];
  projectsFlag: boolean = false;

  usersCount: number = 0;
  usersFlag: boolean = false;


  constructor(private projectService: ProjectService,
              private userService: UserService,
              private teamService: TeamService) {
    this.projectService.getProjects();
    this.teamService.getTeams();
    this.userService.getUsers();
  }

  ngOnInit() {
    this.teamService.teamsChange.subscribe(result => {
      this.teams  = result;
    });

    this.projectService.projectsChange.subscribe(result => {
      this.projects = result;
    });

    this.projectService.projectChange.subscribe(result => {
      this.projectService.getProjects();
    });

    this.userService.usersChange.subscribe(result => {
        this.usersCount = result.length;
      },
      error => {
        this.usersFlag = true;
      });
  }
}
