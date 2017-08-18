import { Component, OnInit } from '@angular/core';
import {ModalService} from "../../services/modal.service";
import {Router, ActivatedRoute} from "@angular/router";
import {TeamService} from "../../services/team.service";
import {Team} from "../../domain/team";
import {Project} from "../../domain/project";
import {User} from "../../domain/user";


@Component({
  selector: 'app-team',
  templateUrl: './team.component.html',
  providers: [ ModalService ]
})
export class TeamComponent implements OnInit {

  team: Team;
  projects: Project[];
  users: User[];
  teamName: string;


  constructor(private teamService: TeamService,
              private route: ActivatedRoute,
              private router: Router,
              public modalService: ModalService) { }

  ngOnInit() {
    let id = this.route.snapshot.params['id'];
    this.teamService.getTeam(id);

    this.route.params.subscribe(params => {
      this.teamService.getTeam(params['id']);
    });

    this.teamService.teamChange.subscribe(result => {
      this.team = result;
      this.projects = this.team.projects;
      this.users = this.team.users;
      this.teamName = this.team.name;
    });
  }
}
