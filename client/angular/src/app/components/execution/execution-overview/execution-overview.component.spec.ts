import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ExecutionOverviewComponent } from './execution-overview.component';

describe('ExecutionOverviewComponent', () => {
  let component: ExecutionOverviewComponent;
  let fixture: ComponentFixture<ExecutionOverviewComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ExecutionOverviewComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ExecutionOverviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
