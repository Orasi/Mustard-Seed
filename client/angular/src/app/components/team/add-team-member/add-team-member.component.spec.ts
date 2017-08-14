import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddTeamMemberComponent } from './add-team-member.component';

describe('AddUserComponent', () => {
  let component: AddTeamMemberComponent;
  let fixture: ComponentFixture<AddTeamMemberComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddTeamMemberComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddTeamMemberComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
