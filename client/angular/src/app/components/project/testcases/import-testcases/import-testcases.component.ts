import { Component, OnInit, ViewChild } from '@angular/core';
import { DropzoneConfigInterface } from 'ngx-dropzone-wrapper';
import { ModalService } from "../../../../services/modal.service";


@Component({
  selector: 'app-import-testcases',
  templateUrl: './import-testcases.component.html'
})
export class ImportTestcasesComponent implements OnInit {

  public disabled: boolean = false;

  public config: DropzoneConfigInterface = {
    url: "/projects/:id/parse",
    clickable: true,
    maxFiles: 1,
    autoReset: null,
    errorReset: null,
    cancelReset: null
  };

  constructor(public modalService: ModalService) { }

  ngOnInit() {

  }


  onUploadError(args: any) {
    console.log(this.config.url);
    console.log('onUploadError:', args);
  }

  onUploadSuccess(args: any) {
    console.log('onUploadSuccess:', args);
  }

}
