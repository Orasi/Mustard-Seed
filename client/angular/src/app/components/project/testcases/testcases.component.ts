import { Component, OnInit, Input } from '@angular/core';
import { TestCase } from "../../../domain/testcases/testcase";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-testcases',
  templateUrl: './testcases.component.html',
  providers: [ ModalService ]
})
export class TestcasesComponent implements OnInit {

  @Input() testcases: TestCase[];


  constructor(public modalService: ModalService) { }

  ngOnInit() {
  }

}
