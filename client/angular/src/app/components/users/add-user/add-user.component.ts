import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from "@angular/forms";
import { matchingPasswords, emailValidator } from "../../../validators/validators";
import { User } from "../../../domain/user";
import { UserService } from "../../../services/user.service";
import { ModalService } from "../../../services/modal.service";


@Component({
  selector: 'app-add-user',
  templateUrl: './add-user.component.html'
})
export class AddUserComponent implements OnInit {

  @Output() onAddUserEvent: EventEmitter<User> = new EventEmitter<User>();

  addUserFormGroup: FormGroup;

  errorFlag: boolean = false;
  userNameValue: string;
  firstNameValue: string;
  lastNameValue: string;
  emailValue: string;
  passwordValue: string;
  confirmPasswordValue: string;
  companyValue: string;

  constructor(private fb: FormBuilder,
              private userService: UserService,
              public modalService: ModalService) {

    this.addUserFormGroup = fb.group({
      'username': ['', Validators.required],
      'email': ['', Validators.compose([Validators.required,  emailValidator])],
      'firstName': ['', Validators.required],
      'lastName': ['', Validators.required],
      'password': ['', Validators.required],
      'confirmPassword': ['', Validators.required],
      'company': ['', Validators.required],
      'admin': ['']
    }, { validator: matchingPasswords('password', 'confirmPassword') });

    this.modalService.resetForm.subscribe(value => {
      this.addUserFormGroup.reset(value);
    });
  }

  ngOnInit() {
    this.userNameValue = '';
    this.firstNameValue = '';
    this.lastNameValue = '';
    this.emailValue = '';
    this.passwordValue = '';
    this.confirmPasswordValue = '';
    this.companyValue = '';
  }

  register(values: any) {
    let jsonObject = {
      user: {
        first_name: values.firstName,
        last_name: values.lastName,
        password: values.password,
        password_confirmation: values.confirmPassword,
        username: values.username,
        email: values.email,
        company: values.company
      }
    };

    this.userService.createUser(jsonObject).subscribe(result => {
        this.onAddUserEvent.emit(result);
        this.modalService.closeModal();
    },
    err => {
      this.errorFlag = true;
    });
  }
}
