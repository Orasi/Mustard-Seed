import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ExecutionStatusComponent } from './execution-status.component';

describe('ExecutionStatusComponent', () => {
  let component: ExecutionStatusComponent;
  let fixture: ComponentFixture<ExecutionStatusComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ExecutionStatusComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ExecutionStatusComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
