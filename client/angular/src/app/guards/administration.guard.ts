import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { UserService } from "../services/user.service";


@Injectable()
export class AdministrationGuard implements CanActivate {
  constructor(private router: Router, private userService: UserService) { }

  canActivate() {
    if (this.userService.isAdmin()) {
      return true;
    }

    this.router.navigate(['login'], { queryParams: { admin: false } });
    return false;
  }
}
