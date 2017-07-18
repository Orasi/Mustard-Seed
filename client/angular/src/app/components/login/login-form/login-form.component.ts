import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { AuthenticationService } from "../../../services/authentication.service";


@Component({
  selector: 'login-form',
  templateUrl: './login-form.component.html'
})
export class LoginFormComponent implements OnInit {

  loginForm: FormGroup;
  authenticationFlag: boolean = true;
  adminFlag: boolean = false;


  constructor(private route: ActivatedRoute,
              private fb: FormBuilder,
              private router: Router,
              private authenticationService: AuthenticationService) { }


  ngOnInit() {
    this.route
      .queryParams
      .subscribe(params => {
        if (params['admin'] == 'false') {
          this.adminFlag = true; // must be an admin to perform action, show error
        }
      });

    this.loginForm = this.fb.group({
      'username': ['', Validators.required],
      'password': ['', Validators.required]
    });

    this.authenticationService.logout(); // reset login status
  }


  login(values) {
    this.authenticationService.login(values.username, values.password)
      .subscribe(result => {
          this.router.navigate(['']);
      },
      err => {
        this.authenticationFlag = false;
      });
  }
}
