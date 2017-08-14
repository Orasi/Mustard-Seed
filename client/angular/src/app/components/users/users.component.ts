import { Component, OnInit, Renderer2 } from '@angular/core';
import { User } from "../../domain/user";
import { UserService } from "../../services/user.service";
import { ModalService } from "../../services/modal.service";


@Component({
  selector: 'app-user',
  templateUrl: './users.component.html',
  providers: [ ModalService ]
})
export class UsersComponent implements OnInit {

  users: User[];

  constructor(private userService: UserService,
              public modalService: ModalService) {
    this.userService.getUsers();
  }

  ngOnInit() {
    this.userService.usersChange.subscribe(result => {
      this.users = result;
    });
  }

  addUser(user: User) {
    this.users.push(user);
  }

  toUser($event: any, id: number) {
    // TODO add route to team
    alert("Add route to user");
  }
}
