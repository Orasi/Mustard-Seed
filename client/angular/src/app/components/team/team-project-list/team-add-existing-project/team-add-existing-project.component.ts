import {Component, OnInit, Input} from '@angular/core';
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

  @Input() projects: Project[] = [];
  private selectedValue: string = "";

  
  constructor(private teamService: TeamService,
              private projectService: ProjectService,
              private route: ActivatedRoute,
              public modalService: ModalService) { }

  ngOnInit() {
    this.projectService.getProjects();

    this.projectService.projectsChange.subscribe(result => {
      this.select2Data = [];
      this.select2Data.push({ id: "-1", text: "" });
      for (let project of result) {
        if (!this.doesTeamContainProject(project)) {
          this.select2Data.push({id: String(project.id), text: project.name});
        }
      }
    });

    this.teamService.teamChange.subscribe(result => {
      this.projects = result.projects;
      this.projectService.getProjects();
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
    let teamId = this.route.snapshot.params['id'];

    if (this.selectedValue != "") {
      this.teamService.addProject(teamId, this.selectedValue);
      this.modalService.closeModal();
    }
  }

  doesTeamContainProject(project: Project): boolean {
    if (this.projects != null) {
      for (let teamProject of this.projects) {
        if (teamProject.id == project.id) {
          return true;
        }
      }
    }
    return false;
  }
}
