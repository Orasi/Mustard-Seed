import { TestBed, inject } from '@angular/core/testing';

import { TestCaseService } from './testcase.service';

describe('TestcaseService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [TestCaseService]
    });
  });

  it('should be created', inject([TestCaseService], (service: TestCaseService) => {
    expect(service).toBeTruthy();
  }));
});
