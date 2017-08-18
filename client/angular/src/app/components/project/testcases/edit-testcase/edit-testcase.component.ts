import {Component, OnInit, Inject} from '@angular/core';
import { ModalService } from "../../../../services/modal.service";

@Component({
  selector: 'app-edit-testcase',
  templateUrl: './edit-testcase.component.html'
})
export class EditTestcaseComponent implements OnInit {

  constructor(@Inject('EditTestCaseModalService') public editTestCaseModalService: ModalService) { }

  ngOnInit() {
  }
}
