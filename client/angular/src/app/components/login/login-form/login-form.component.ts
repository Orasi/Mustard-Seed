import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { LoginService } from "../../../services/login.service";
import { User } from "../../../domain/user";

@Component({
  selector: 'login-form',
  templateUrl: './login-form.component.html'
})
export class LoginFormComponent {

  loginForm: FormGroup;
  post: any;
  username: string;
  password: string;
  user: User;
  errorMessage: string;


  constructor(private fb: FormBuilder, private loginService: LoginService) {
    this.loginForm = fb.group({
      'username': [null, Validators.required],
      'password': [null, Validators.required]
    });
  }

  login(post) {
    this.username = post.username;
    this.password = post.password;

    this.loginService.login(this.username, this.password)
      .subscribe(user => this.user = user,
      error => this.errorMessage = <any> error);
  }
}
