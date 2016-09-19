class Step < ApplicationRecord

  default_scope{ where(deleted: [false, nil])}

  belongs_to :testcase
end
