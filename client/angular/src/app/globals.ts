'use strict';
import { Headers, RequestOptions } from '@angular/http';


//<editor-fold desc="Global Constants">

export const mustardUrl: string = 'http://localhost:3000';

//</editor-fold>


//<editor-fold desc="Global Functions">

export function getTokenHeaders(): RequestOptions {
  let token = JSON.parse(localStorage.getItem('currentUser')).token;
  let headers = new Headers({ 'Content-Type': 'application/json', "User-Token": token });
  return new RequestOptions({ headers: headers });
}

export function isEmptyObject(obj) {
  for(var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
      return false;
    }
  }

  return true;
}
//</editor-fold>
