import { Component, OnInit, Input } from '@angular/core';
import { Keyword } from "../../../domain/keyword";


@Component({
  selector: 'app-keywords',
  templateUrl: './keywords.component.html'
})
export class KeywordsComponent implements OnInit {

  @Input() keywords: Keyword[];

  constructor() { }

  ngOnInit() {
  }

}
