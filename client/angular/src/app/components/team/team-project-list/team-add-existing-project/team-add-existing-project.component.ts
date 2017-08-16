import { Component, OnInit } from '@angular/core';
import { FormGroup } from "@angular/forms";
import { ProjectService } from "../../../../services/project.service";
import { Project } from "../../../../domain/project";
import { ModalService } from "../../../../services/modal.service";
import { TeamService } from "../../../../services/team.service";
import { Select2OptionData } from 'ng2-select2';
import { ActivatedRoute } from "@angular/router";


@Component({
  selector: 'app-team-add-existing-project',
  templateUrl: './team-add-existing-project.component.html'
})
export class TeamAddExistingProjectComponent implements OnInit {

  select2Data: Array<Select2OptionData>;
  options: Select2Options;

  projects: Project[] = [];

  addProjectFormGroup: FormGroup;

  private selectedValue: string = "";
  private teamId: string;


  constructor(private teamService: TeamService,
              private projectService: ProjectService,
              private route: ActivatedRoute,
              public modalService: ModalService) {
    this.teamId = this.route.snapshot.params['id'];
    this.projectService.getProjects();
  }

  ngOnInit() {
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

  public changed(event: any): void {
    this.selectedValue = event.value;
  }

  addProjectToTeam() {
    if (this.selectedValue != "") {
      this.teamService.addProject(this.teamId, this.selectedValue);
      this.modalService.closeModal();
    }
  }
}
