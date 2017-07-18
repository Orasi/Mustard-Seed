import { Component, OnInit } from '@angular/core';
import { UserService } from "../../../services/user.service";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { emailValidator } from '../../../validators/validators';


@Component({
  selector: 'forgot-password-form',
  templateUrl: './forgot-password-form.component.html'
})
export class ForgotPasswordFormComponent implements OnInit {

  forgotPasswordForm: FormGroup;

  constructor(private fb: FormBuilder, private userService: UserService) { }

  ngOnInit() {
    this.forgotPasswordForm = this.fb.group({
      'email': ['', Validators.compose([Validators.required,  emailValidator])]
    });
  }

  resetPassword(values) {
    this.userService.sendPasswordResetEmail(values.email);
  }
}
