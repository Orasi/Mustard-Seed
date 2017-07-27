import { TestBed, inject } from '@angular/core/testing';

import { TestcaseService } from './testcase.service';

describe('TestcaseService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [TestcaseService]
    });
  });

  it('should be created', inject([TestcaseService], (service: TestcaseService) => {
    expect(service).toBeTruthy();
  }));
});
