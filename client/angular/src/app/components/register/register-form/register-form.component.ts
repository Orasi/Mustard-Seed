import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { User } from "../../../domain/user";
import { UserService } from "../../../services/user.service";
import { emailValidator, matchingPasswords } from '../../../validators/validators';


@Component({
  selector: 'register-form',
  templateUrl: './register-form.component.html'
})
export class RegisterFormComponent {

  registerForm: FormGroup;

  constructor(private fb: FormBuilder, private userService: UserService) {
    this.registerForm = fb.group({
      'username': ['', Validators.required],
      'email': ['', Validators.compose([Validators.required,  emailValidator])],
      'firstName': ['', Validators.required],
      'lastName': ['', Validators.required],
      'password': ['', Validators.required],
      'confirmPassword': ['', Validators.required],
    }, { validator: matchingPasswords('password', 'confirmPassword') });
  }
}
