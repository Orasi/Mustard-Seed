import { Component, OnInit, Input } from '@angular/core';
import { Router } from "@angular/router";
import { Team } from "../../../domain/team";
import { TeamService } from "../../../services/team.service";
import { AuthenticationService } from "../../../services/authentication.service";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-team-list',
  templateUrl: './team-list.component.html',
  providers: [ ModalService ]
})
export class TeamListComponent implements OnInit {

  @Input() teams: Team[];

  userName: string;

  constructor(private teamService: TeamService,
              private router: Router,
              public modalService: ModalService) { }

  ngOnInit() {
    if (localStorage.getItem('currentUser')) {
      this.userName = JSON.parse(localStorage.getItem('currentUser')).name;
    } else {
      AuthenticationService.logout();
      this.router.navigate(['/login']);
    }
  }

  addTeam(team: Team) {
    this.teams.push(team);
  }

  toTeam($event: any, id: number) {
    // TODO add route to team
    alert("Add route to team");
  }
}
