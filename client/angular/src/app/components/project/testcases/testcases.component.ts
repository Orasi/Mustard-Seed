import { Component, OnInit, Input } from '@angular/core';
import { TestCase } from "../../../domain/testcases/testcase";


@Component({
  selector: 'app-testcases',
  templateUrl: './testcases.component.html'
})
export class TestcasesComponent implements OnInit {

  @Input() testcases: TestCase[];

  constructor() { }

  ngOnInit() {
  }

}
