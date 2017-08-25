import { Component, OnInit, Inject } from '@angular/core';
import { TestCase } from "../../../domain/testcases/testcase";
import { ModalService } from "../../../services/modal.service";
import { ProjectService } from "../../../services/project.service";
import { TestCaseService } from "../../../services/testcase.service";
import { TestCaseDetails } from "../../../domain/testcases/testcase-details";
import * as $ from 'jquery';


@Component({
  selector: 'app-testcases',
  templateUrl: './testcases.component.html',
  providers: [ ModalService,
    { provide: 'EditTestCaseModalService', useClass: ModalService },
    { provide: 'ImportTestCaseModalService', useClass: ModalService }]
})
export class TestcasesComponent implements OnInit {

  testcases: TestCase[];
  testcase: TestCaseDetails;


  constructor(private projectService: ProjectService,
              private testcaseService: TestCaseService,
              @Inject('ImportTestCaseModalService') public importTestCaseModalService: ModalService,
              @Inject('EditTestCaseModalService') public editTestCaseModalService: ModalService) { }

  ngOnInit() {
    this.projectService.projectChange.subscribe(result => {
      this.testcases = result.testcases;

      if (this.testcases != null) {
        this.sortTestcasesById(this.testcases);
      }
    });

    this.testcaseService.testcaseChange.subscribe(result => {
      this.testcase = result;
    });
  }

  setTargetedTestCase(event: any) {
    let testcaseId = $(event.target).closest('tr').attr('id');
    this.testcaseService.getTestCaseDetails(testcaseId);
  }

  sortTestcasesById(array) {
    array.sort(function(a, b){
      var aId = Number(a.testcaseId), bId = Number(b.testcaseId);
      if (aId < bId) //sort string ascending
        return -1;
      if (aId > bId)
        return 1;
      return 0; //default return value (no sorting)
    });
  }
}
