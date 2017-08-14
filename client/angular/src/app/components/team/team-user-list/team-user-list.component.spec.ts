import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { TeamUserListComponent } from './team-user-list.component';


describe('UserListComponent', () => {
  let component: TeamUserListComponent;
  let fixture: ComponentFixture<TeamUserListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TeamUserListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TeamUserListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
