import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from "../../services/authentication.service";
import { Router } from "@angular/router";


@Component({
  selector: 'app-header',
  templateUrl: './header.component.html'
})
export class HeaderComponent implements OnInit {

  username: string;

  constructor(private router: Router) { }

  ngOnInit() {
    this.username = JSON.parse(localStorage.getItem('currentUser')).name
  }

  logout() {
    AuthenticationService.logout();
    this.router.navigate(["/login"]);
  }
}
