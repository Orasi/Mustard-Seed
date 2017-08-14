import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TeamProjectListComponent } from './team-project-list.component';

describe('TeamProjectListComponent', () => {
  let component: TeamProjectListComponent;
  let fixture: ComponentFixture<TeamProjectListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TeamProjectListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TeamProjectListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
