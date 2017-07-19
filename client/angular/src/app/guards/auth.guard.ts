import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';


@Injectable()
export class AuthenticationGuard implements CanActivate {

  constructor(private router: Router) { }

  canActivate() {
    if (localStorage.getItem('currentUser')) {
      return true; // user is logged in
    }

    this.router.navigate(['login']);
    return false; // user is not logged in, send to home page
  }
}
