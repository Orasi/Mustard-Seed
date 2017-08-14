import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from "@angular/forms";
import { TeamService } from "../../../services/team.service";
import { Team } from "../../../domain/team";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-add-team-member',
  templateUrl: './add-team-member.component.html'
})
export class AddTeamMemberComponent implements OnInit {

  @Output() onAddUserEvent: EventEmitter<Team> = new EventEmitter<Team>();

  addUserFormGroup: FormGroup;
  users: IUser[];
  nameFlag: boolean = false;

  constructor(private fb: FormBuilder,
              private teamService: TeamService,
              public modalService: ModalService) { }

  ngOnInit() {
    this.addUserFormGroup = this.fb.group({
      'select2': ['', Validators.required]
    });

    this.modalService.resetForm.subscribe(value => {
      this.addUserFormGroup.reset(value);
    });
  }

  addUserToTeam(values) {
    this.teamService.addUser(values.name, values.description).subscribe(result => {
        this.onAddUserEvent.emit(result);
        this.modalService.closeModal();
      },
      err => {
        if (err.messages[0] == "Name has already been taken") {
          this.nameFlag = true;
        }
      });
  }
}

interface IUser {
  id: number;
  name: string;
}
