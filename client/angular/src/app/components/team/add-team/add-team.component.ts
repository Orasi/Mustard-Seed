import { Component, OnInit, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { TeamService } from "../../../services/team.service";
import { Team } from "../../../domain/team";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-add-team',
  templateUrl: './add-team.component.html'
})
export class AddTeamComponent implements OnInit {

  addTeamFormGroup: FormGroup;
  nameValue : string;
  descriptionValue : string;
  nameFlag: boolean = false; //TODO add for creating another team with the same name


  constructor(private fb: FormBuilder,
              private teamService: TeamService,
              public modalService: ModalService) { }

  ngOnInit() {
    this.nameValue = '';
    this.descriptionValue = '';

    this.addTeamFormGroup = this.fb.group({
      'name': ['', Validators.required],
      'description': ['', Validators.required]
    });

    this.modalService.resetForm.subscribe(value => {
      this.addTeamFormGroup.reset(value);
    });
  }

  createTeam(values) {
    this.teamService.createTeam(values.name, values.description);
    this.modalService.closeModal();
  }
}
