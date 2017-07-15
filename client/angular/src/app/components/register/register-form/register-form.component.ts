import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { User } from "../../../domain/user";
import { RegisterService } from "../../../services/register.service";


@Component({
  selector: 'register-form',
  templateUrl: './register-form.component.html'
})
export class RegisterFormComponent {

  registerForm: FormGroup;
  post: any;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  password: string;
  confirmPassword: string;
  user: User;
  errorMessage: string;

  constructor(private fb: FormBuilder, private registerService: RegisterService) {
    this.registerForm = fb.group({
      'username': [null, Validators.required],
      'email': [null, Validators.required],
      'firstName': [null, Validators.required],
      'lastName': [null, Validators.required],
      'password': [null, Validators.required],
      'confirmPassword': [null, Validators.required],
    });
  }
}
