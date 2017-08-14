import { Renderer2, Injectable } from '@angular/core';
import { Subject, Observable } from "rxjs";


@Injectable()
export class ModalService {

  resetForm: Observable<boolean>;
  private resetFormSubject: Subject<boolean>;

  show: boolean = false;

  constructor(private renderer: Renderer2) {
    this.resetFormSubject = new Subject<boolean>();
    this.resetForm = this.resetFormSubject.asObservable();
  }

  public openModal() {
    this.renderer.addClass(document.body, 'modal-open');
    this.show = !this.show;
  }

  public closeModal(callback?: () => void) {
    this.show = false;
    this.renderer.removeClass(document.body, 'modal-open');
    if (callback) {
      callback();
    }
  }

  public handleClick(event) {
    let target = event.target || event.srcElement || event.currentTarget;
    let modalDialog = document.getElementsByClassName('modal-dialog')[0];
    if (!modalDialog.contains(target)) {
      this.closeModal();
      this.resetFormSubject.next(true);
    }
  }
}
