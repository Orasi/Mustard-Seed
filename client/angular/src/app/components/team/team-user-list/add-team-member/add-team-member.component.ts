import {Component, OnInit, Input} from '@angular/core';
import { TeamService } from "../../../../services/team.service";
import { ModalService } from "../../../../services/modal.service";
import { User } from "../../../../domain/user";
import { Select2OptionData } from 'ng2-select2';
import { ActivatedRoute } from "@angular/router";
import { UserService } from "../../../../services/user.service";


@Component({
  selector: 'app-add-team-member',
  templateUrl: './add-team-member.component.html'
})
export class AddTeamMemberComponent implements OnInit {

  select2Data: Array<Select2OptionData>;
  options: Select2Options;

  @Input() teamUsers: User[] = [];
  noUsersFlag: boolean = false;
  
  private selectedValue: string = "";


  constructor(private userService: UserService,
              private teamService: TeamService,
              private route: ActivatedRoute,
              public modalService: ModalService) { }

  ngOnInit() {
    this.userService.getUsers();

    this.userService.usersChange.subscribe(result => {
      this.select2Data = [];
      this.select2Data.push({ id: "-1", text: "" });

      for (let user of result) {
        if (!this.doesTeamContainUser(user)) {
          let name = user.firstName + " " + user.lastName;
          this.select2Data.push({id: String(user.id), text: name});
        }
      }
    });
    
    this.teamService.teamChange.subscribe(result => {
      this.userService.getUsers();
    });

    this.options = {
      placeholder: { id: "-1", text: "Select Project" },
      minimumResultsForSearch: 5
    }
  }

  public changed(event: any): void {
    this.selectedValue = event.value;
  }

  addUserToTeam() {
    let teamId = this.route.snapshot.params['id'];
    if (this.selectedValue != "") {
      this.teamService.addUser(teamId, this.selectedValue);
      this.modalService.closeModal();
      this.userService.getUsers();
    }
  }

  doesTeamContainUser(user: User): boolean {
    if (this.teamUsers != null) {
      for (let teamUser of this.teamUsers) {
        if (teamUser.id == user.id) {
          return true;
        }
      }
    }
    return false;
  }
}
