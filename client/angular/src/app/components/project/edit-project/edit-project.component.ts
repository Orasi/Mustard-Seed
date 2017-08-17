import { Component, OnInit, Output, EventEmitter, Input } from '@angular/core';
import { Project } from "../../../domain/project";
import { Router } from "@angular/router";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { ProjectService } from "../../../services/project.service";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-edit-project',
  templateUrl: './edit-project.component.html'
})
export class EditProjectComponent implements OnInit {

  @Output() onEditProjectEvent: EventEmitter<Project> = new EventEmitter<Project>();
  @Output() onDeleteProjectEvent: EventEmitter<boolean> = new EventEmitter<boolean>();
  @Input() project: Project;

  editProjectFormGroup: FormGroup;
  nameValue : string;

  constructor(private fb: FormBuilder,
              private projectService: ProjectService,
              private router: Router,
              public modalService: ModalService) { }

  ngOnInit() {
    this.nameValue = '';

    this.editProjectFormGroup = this.fb.group({
      'name': ['', Validators.required]
    });
  }

  editProject(values){
    this.projectService.editProject(this.project.id, values.name);
    this.modalService.closeModal();
  }

  deleteProject() {
    this.projectService.deleteProject(this.project.id);
    this.modalService.closeModal();
    this.router.navigate(['/projects']);
  }
}
