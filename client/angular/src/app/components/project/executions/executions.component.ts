import { Component, OnInit, Input } from '@angular/core';
import { Execution } from "../../../domain/executions/execution";


@Component({
  selector: 'app-executions',
  templateUrl: './executions.component.html'
})
export class ExecutionsComponent implements OnInit {

  @Input() executions: Execution[];

  constructor() { }

  ngOnInit() {
  }

}
