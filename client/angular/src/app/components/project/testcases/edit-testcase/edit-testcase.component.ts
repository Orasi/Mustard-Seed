import { Component, OnInit, Inject, Input } from '@angular/core';
import { ModalService } from "../../../../services/modal.service";
import { Select2OptionData } from 'ng2-select2';
import { FormGroup, FormBuilder, Validators } from "@angular/forms";
import { TestCaseService } from "../../../../services/testcase.service";
import { TestCaseDetails } from "../../../../domain/testcases/testcase-details";
import { ProjectService } from "../../../../services/project.service";
import { Keyword } from "../../../../domain/keyword";
import * as $ from 'jquery';


@Component({
  selector: 'app-edit-testcase',
  templateUrl: './edit-testcase.component.html'
})
export class EditTestcaseComponent implements OnInit {

  testcase: TestCaseDetails;
  keywords: Keyword[];
  keywordOptionsData: Array<Select2OptionData>;
  options: Select2Options;
  value: string[];
  current: string;
  editTestCaseFormGroup: FormGroup;

  nameValue: string;
  validationIdValue: string;


  constructor(private fb: FormBuilder,
              private testcaseService: TestCaseService,
              private projectService: ProjectService,
              @Inject('EditTestCaseModalService') public editTestCaseModalService: ModalService) { }

  ngOnInit() {
    this.projectService.projectChange.subscribe(result => {
      // Set all the keywords for Select2
      if (result.keywords) {
        for (let keyword of result.keywords) {
          this.keywordOptionsData.push({id: String(keyword.id), text: keyword.keyword});
        }
      }
    });

    this.testcaseService.testcaseChange.subscribe(result => {
      this.testcase = result;
      this.nameValue = this.testcase.name;
      this.validationIdValue = this.testcase.testcaseId;

      if (this.testcase.keywords) {
        for (let keyword of this.testcase.keywords) {
          this.value.push(String(keyword.id));
        }
      }

      if (this.value) {
        this.current = this.value.join(' | ');
      }

      this.editTestCaseFormGroup = this.fb.group({
        'name':         [this.nameValue, Validators.required],
        'validationId': [this.validationIdValue, Validators.required]
      });
    });

    this.options = {
      multiple: true
    };
  }

  changed(data: { value: string[] }) {
    this.current = data.value.join(' | ');
  }

  moveStepDown(event: any) {
    let $panel = $(event.target).closest('.panel');


  }

  moveStepUp(event: any) {

  }

  deleteStep(event: any) {

  }
}
