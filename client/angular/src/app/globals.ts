'use strict';
import { Headers, RequestOptions } from '@angular/http';


export const mustardUrl: string = 'http://localhost:3000';

export function getTokenHeaders(): RequestOptions {
  let token = JSON.parse(localStorage.getItem('currentUser')).token;
  let headers = new Headers({ 'Content-Type': 'application/json', "User-Token": token });
  return new RequestOptions({ headers: headers });
}
