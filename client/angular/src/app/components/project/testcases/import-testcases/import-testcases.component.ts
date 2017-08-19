import {Component, OnInit, ChangeDetectorRef, Inject} from '@angular/core';
import { DropzoneConfigInterface } from 'ngx-dropzone-wrapper';
import { ModalService } from "../../../../services/modal.service";
import { ActivatedRoute } from "@angular/router";
import * as Globals from '../../../../globals';
import * as $ from 'jquery';
import { ProjectService } from "../../../../services/project.service";
import { TestCaseService } from "../../../../services/testcase.service";


@Component({
  selector: 'app-import-testcases',
  templateUrl: './import-testcases.component.html'
})
export class ImportTestcasesComponent implements OnInit {

  public disabled: boolean = false;

  public config: DropzoneConfigInterface = {
    url: "",
    clickable: true,
    maxFiles: 1,
    autoReset: null,
    errorReset: null,
    cancelReset: null
  };

  successTestcases = [];
  failureTestcases = [];
  hasPreview: boolean = false;


  constructor(private changeDetector: ChangeDetectorRef,
              private route: ActivatedRoute,
              private testcaseService: TestCaseService,
              private projectService: ProjectService,
              @Inject('ImportTestCaseModalService') public importTestCaseModalService: ModalService) { }

  ngOnInit() {
    let id = this.route.snapshot.params['id'];
    this.config.url = Globals.mustardUrl + "/projects/" + id + "/parse";
  }

  onUploadSuccess(args: any) {
    for (let testcase of args[1].success) {
      this.successTestcases.push({
        name: testcase.name,
        validation_id: testcase.validation_id,
        reproduction_steps: testcase.reproduction_steps
      });
    }

    for (let message of args[1].failure) {
      this.failureTestcases.push({ error: message });
    }

    // Sort numerically and trigger changes for template
    this.sortTestcasesByValidationId(this.successTestcases);
    this.hasPreview = true;
    this.changeDetector.detectChanges();
  }

  importTestcases() {
    let id = this.route.snapshot.params['id'];
    this.testcaseService.importTestcases(id, JSON.stringify(this.successTestcases));
    this.projectService.getProject(Number(id));
  }

  onClick(event) {
    let $target = $(event.target);
    let $panel = $target.closest('div.panel');
    let $icon = $target.find('i');
    let $panelBody = $panel.find('.panel-body');

    $panelBody.slideToggle(300);

    $icon.toggleClass('fa-chevron-down').toggleClass('fa-chevron-up');
    $panel.toggleClass('').toggleClass('panel-collapse');
    setTimeout(function () {
      $panel.resize();
    }, 50);
  }

  sortTestcasesByValidationId(array) {
    array.sort(function(a, b){
      var aValidationId = Number(a.validationId), bValidationId = Number(b.validationId);
      if (aValidationId < bValidationId) //sort string ascending
        return -1;
      if (aValidationId > bValidationId)
        return 1;
      return 0; //default return value (no sorting)
    });
  }
}
