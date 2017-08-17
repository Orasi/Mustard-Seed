import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { DropzoneConfigInterface } from 'ngx-dropzone-wrapper';
import { ModalService } from "../../../../services/modal.service";
import { ActivatedRoute } from "@angular/router";
import * as Globals from '../../../../globals';
import * as $ from 'jquery';


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

  successTestcases: ImportedTestcase[] = [];
  failureTestcases = [];


  constructor(private changeDetector: ChangeDetectorRef,
              private route: ActivatedRoute,
              public modalService: ModalService) { }

  ngOnInit() {
    let id = this.route.snapshot.params['id'];
    this.config.url = Globals.mustardUrl + "/projects/" + id + "/parse";
  }


  onUploadError(args: any) {
    console.log(this.config.url);
    console.log('onUploadError:', args);
  }

  onUploadSuccess(args: any) {
    console.log('onUploadSuccess:', args);
    console.log(args[1].success);
    for (let testcase of args[1].success) {
      this.successTestcases.push({ name: testcase.name, validationId: testcase.validation_id });
    }

    for (let message of args[1].failure) {
      this.failureTestcases.push({ error: message });
    }

    this.sortTestcasesByValidationId(this.successTestcases);
    this.changeDetector.detectChanges();
  }

  onClick(event) {
    let $target = $(event.target);
    let $panel = $target.closest('div.panel');
    let $icon = $target.closest('i');
    let $panelBody = $panel.find('.panel-body');

    $panelBody.slideToggle(300);

    $icon.toggleClass('fa-chevron-up').toggleClass('fa-chevron-down');
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

interface ImportedTestcase {
  name: string;
  validationId: string;
}
