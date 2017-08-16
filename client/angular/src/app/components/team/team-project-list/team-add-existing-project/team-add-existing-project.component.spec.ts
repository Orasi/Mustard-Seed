import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TeamAddExistingProjectComponent } from './team-add-existing-project.component';

describe('TeamAddExistingProjectComponent', () => {
  let component: TeamAddExistingProjectComponent;
  let fixture: ComponentFixture<TeamAddExistingProjectComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TeamAddExistingProjectComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TeamAddExistingProjectComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
