import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { ProjectService } from "../../../services/project.service";
import { Project } from "../../../domain/project";
import { ModalService } from "../../../services/modal.service";
import { TeamService } from "../../../services/team.service";
import { Select2OptionData } from 'ng2-select2';


@Component({
  selector: 'app-team-add-existing-project',
  templateUrl: './team-add-existing-project.component.html'
})
export class TeamAddExistingProjectComponent implements OnInit {

  select2Data: Array<Select2OptionData>;
  options: Select2Options;

  projects: Project[] = [];

  addProjectFormGroup: FormGroup;
  nameValue : string;
  nameFlag: boolean = false;

  constructor(private fb: FormBuilder,
              private teamService: TeamService,
              private projectService: ProjectService,
              public modalService: ModalService) {
    this.projectService.getProjects();
  }

  ngOnInit() {
    this.nameValue = '';

    this.addProjectFormGroup = this.fb.group({
      'select2': ['', Validators.required]
    });

    this.modalService.resetForm.subscribe(value => {
      this.addProjectFormGroup.reset(value);
    });

    this.projectService.projectsChange.subscribe(result => {
      this.projects = result;

      this.select2Data = [];
      this.select2Data.push({ id: "-1", text: "" });
      for (let project of this.projects) {
        this.select2Data.push({ id: String(project.id), text: project.name });
      }
    });

    this.options = {
      placeholder: { id: "-1", text: "Select Project" },
      minimumResultsForSearch: 5
    }
  }


  addUserToTeam(values) {
    this.teamService.addProject(values.name, values.description);
    this.modalService.closeModal();
  }
}
