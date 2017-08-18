import {Component, OnInit, Input, Inject} from '@angular/core';
import { TestCase } from "../../../domain/testcases/testcase";
import { ModalService } from "../../../services/modal.service";
import {ProjectService} from "../../../services/project.service";


@Component({
  selector: 'app-testcases',
  templateUrl: './testcases.component.html',
  providers: [ ModalService,
    { provide: 'EditTestCaseModalService', useClass: ModalService },
    { provide: 'ImportTestCaseModalService', useClass: ModalService }]
})
export class TestcasesComponent implements OnInit {

  @Input() testcases: TestCase[];

  constructor(private projectService: ProjectService,
              @Inject('ImportTestCaseModalService') public importTestCaseModalService: ModalService,
              @Inject('EditTestCaseModalService') public editTestCaseModalService: ModalService) { }

  ngOnInit() {
    this.projectService.projectChange.subscribe(result => {
      this.testcases = result.testcases;

      if (this.testcases != null) {
        this.sortTestcasesById(this.testcases);
      }
    });
  }

  sortTestcasesById(array) {
    array.sort(function(a, b){
      var aId = Number(a.id), bId = Number(b.id);
      if (aId < bId) //sort string ascending
        return -1;
      if (aId > bId)
        return 1;
      return 0; //default return value (no sorting)
    });
  }
}
