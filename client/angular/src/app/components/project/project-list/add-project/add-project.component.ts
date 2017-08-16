import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { ProjectService } from "../../../../services/project.service";
import { Project } from "../../../../domain/project";
import { ModalService } from "../../../../services/modal.service";


@Component({
  selector: 'app-add-project',
  templateUrl: './add-project.component.html'
})
export class AddProjectComponent implements OnInit {

  @Output() onAddProjectEvent: EventEmitter<Project> = new EventEmitter<Project>();

  addProjectFormGroup: FormGroup;
  nameValue : string;
  nameFlag: boolean = false;

  constructor(private fb: FormBuilder,
              private projectService: ProjectService,
              public modalService: ModalService) { }

  ngOnInit() {
    this.nameValue = '';

    this.addProjectFormGroup = this.fb.group({
      'name': ['', Validators.required]
    });

    this.modalService.resetForm.subscribe(value => {
      this.addProjectFormGroup.reset(value);
    });
  }

  createProject(values) {
    this.projectService.createProject(values.name);
    this.modalService.closeModal();
  }
}
