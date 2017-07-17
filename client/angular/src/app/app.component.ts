import {Component, OnInit, Input} from '@angular/core';
import { LoginService } from './services/login.service';
import { Meta } from '@angular/platform-browser';
import {RegisterService} from "./services/register.service";


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  providers: [ LoginService, RegisterService ]
})
export class AppComponent implements OnInit {

  title = 'mustard';

  constructor(private metaService: Meta) {

    metaService.addTags([
      { name: 'author',   content: 'clmustard.orasi.com'},
      { name: 'keywords', content: 'angular seo, angular 4 universal, etc'},
      { name: 'description', content: 'This is my Angular SEO-based App, enjoy it!' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1.0' },
      { rel: 'stylesheet', type: 'text/css', href: 'http://fonts.googleapis.com/css?family=Roboto:300,400,500,700,900' }
    ]);
  }

  ngOnInit() {
  }
}
