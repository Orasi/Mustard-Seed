import { Component, OnInit, Input } from '@angular/core';
import { User } from "../../../domain/user";
import { Router } from "@angular/router";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-team-user-list',
  templateUrl: './team-user-list.component.html',
  providers: [ ModalService ]
})
export class TeamUserListComponent implements OnInit {

  @Input() users: User[];

  constructor(private router: Router,
              public modalService: ModalService) { }

  ngOnInit() { }

  addUser(user: User) {
    this.users.push(user);
  }

  toUser($event: any, id: number) {
    // TODO add route to team
    alert("Add route to user");
  }
}
