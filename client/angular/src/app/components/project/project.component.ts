import { Component, OnInit } from '@angular/core';
import { ProjectService } from "../../services/project.service";
import { ExecutionService } from "../../services/execution.service";
import { ActivatedRoute, Router } from "@angular/router";
import { ExecutionStatus } from "../../domain/executions/execution-status";
import { Project } from "../../domain/project";
import { TestCase } from "../../domain/testcases/testcase";
import { Keyword } from "../../domain/keyword";
import { ModalService } from "../../services/modal.service";
import { Execution } from "../../domain/executions/execution";
import { Environment } from "../../domain/environment";


@Component({
  selector: 'app-project',
  templateUrl: './project.component.html',
  providers: [ ModalService ]
})
export class ProjectComponent implements OnInit {

  project: Project;
  testcases: TestCase[];
  executions: Execution[];
  keywords: Keyword[];
  environments: Environment[];
  executionStatus: ExecutionStatus;

  constructor(private projectService: ProjectService,
              private executionService: ExecutionService,
              private route: ActivatedRoute,
              private router: Router,
              public modalService: ModalService) {

    let id = this.route.snapshot.params['id'];
    this.projectService.getProject(id);
    this.getExecutionStatus(id);
  }

  ngOnInit() {

    this.route.params.subscribe(params => {
      this.projectService.getProject(params['id']);
    });

    this.projectService.projectChange.subscribe(result => {
      this.project = result;
      this.testcases = result.testcases;
      this.keywords = result.keywords;
    });
  }

  getExecutionStatus(id: string) {
    this.executionService.getTestCaseStatus(id).subscribe(result => {
      this.executionStatus = result;
    });
  }

  editProject(project: Project) {
    this.project = project;
  }

  deleteProject() {
    this.router.navigate(['/projects']);
  }
}
