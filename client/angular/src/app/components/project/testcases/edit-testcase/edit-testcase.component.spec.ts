import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { EditTestcaseComponent } from './edit-testcase.component';

describe('EditTestcaseComponent', () => {
  let component: EditTestcaseComponent;
  let fixture: ComponentFixture<EditTestcaseComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ EditTestcaseComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EditTestcaseComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
