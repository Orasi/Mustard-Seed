import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ImportTestcasesComponent } from './import-testcases.component';

describe('ImportTestcasesComponent', () => {
  let component: ImportTestcasesComponent;
  let fixture: ComponentFixture<ImportTestcasesComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ImportTestcasesComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ImportTestcasesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
