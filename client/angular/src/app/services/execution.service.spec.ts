import { TestBed, inject } from '@angular/core/testing';

import { ExecutionService } from './execution.service';

describe('ExecutionService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ExecutionService]
    });
  });

  it('should be created', inject([ExecutionService], (service: ExecutionService) => {
    expect(service).toBeTruthy();
  }));
});
