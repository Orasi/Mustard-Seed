import { Component, OnInit, Input } from '@angular/core';
import { User } from "../../../domain/user";
import {Router, ActivatedRoute} from "@angular/router";
import { ModalService } from "../../../services/modal.service";
import {TeamService} from "../../../services/team.service";


@Component({
  selector: 'app-team-user-list',
  templateUrl: './team-user-list.component.html',
  providers: [ ModalService ]
})
export class TeamUserListComponent implements OnInit {

  @Input() users: User[] = [];
  
  private teamId: string;
  

  constructor(private router: Router,
              private teamService: TeamService,
              private route: ActivatedRoute,
              public modalService: ModalService) { }

  ngOnInit() {
    this.teamService.teamChange.subscribe(result => {
        this.users = result.users;
    });
  }

  addUser(user: User) {
    this.users.push(user);
  }

  toUser($event: any, id: number) {
    // TODO add route to team
    alert("Add route to user");
  }

  deleteUserFromTeam($event, index) {
    let teamId = this.route.snapshot.params['id'];
    let userId = $event.target.id;
    this.users.splice(index, 1);
    this.teamService.deleteUser(teamId, userId);
  }
}
