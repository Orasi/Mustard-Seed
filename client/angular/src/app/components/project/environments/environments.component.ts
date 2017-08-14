import {Component, OnInit, Input} from '@angular/core';
import {Environment} from "../../../domain/environment";


@Component({
  selector: 'app-environments',
  templateUrl: './environments.component.html'
})
export class EnvironmentsComponent implements OnInit {

  @Input() environments: Environment[];

  constructor() { }

  ngOnInit() {
  }

}
