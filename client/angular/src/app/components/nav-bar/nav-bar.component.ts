import { Component, OnInit } from '@angular/core';
import { ProjectService } from '../../services/project.service';
import { TeamService } from '../../services/team.service';


@Component({
  selector: 'nav-bar',
  templateUrl: './nav-bar.component.html'
})
export class NavBarComponent implements OnInit {

  constructor(private projectService: ProjectService, private teamService: TeamService) { }

  ngOnInit() {
    this.teamService.getTeam(1).subscribe(result => {
        console.log(result);
      },
      err => {
        console.log(err);
      });
  }
}
