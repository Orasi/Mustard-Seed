import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { UserService } from '../services/user.service';
import {Observable} from "rxjs";


@Injectable()
export class AuthenticationGuard implements CanActivate {

  constructor(private router: Router, private userService: UserService) { }

  canActivate(): Observable<boolean> | boolean {
    return this.userService.isTokenValid().map(data => {
      if (data) {
        return true;
      }
      else {
        this.router.navigate(['/login']);
        return false;
      }
    },
    error => {
      this.router.navigate(['/login']);
      return false;
    });
  }
}
