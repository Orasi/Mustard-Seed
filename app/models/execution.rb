class Execution < ApplicationRecord

  scope :open_execution, ->() { find_by_closed(false) }
  scope :closed, -> {where(closed: true)}

  before_save :default_name

  belongs_to :project, touch: true
  has_many :results, dependent: :destroy

  def default_name
    if self.name.blank?
      self.name = "Execution: #{DateTime.now.strftime('%m/%d/%Y')}"
    end
  end

  def environment_summary
    sql = "SELECT environments.id, environments.uuid, environments.display_name, environments.environment_type, results.pass_count, results.fail_count, results.skip_count, results.updated_at from environments, \
          (SELECT results.environment_id, MAX(results.updated_at) updated_at, \
               Count(CASE \
                       WHEN results.current_status = 'pass' THEN 1\
                       ELSE NULL \
                     END) AS pass_count, \
               Count(CASE \
                       WHEN results.current_status = 'fail' THEN 1 \
                       ELSE NULL \
                     END) AS fail_count, \
               Count(CASE \
                       WHEN results.current_status = 'skip' THEN 1 \
                       ELSE NULL \
                     END) AS skip_count \
          FROM  results \
          WHERE results.execution_id = #{self.id} \
          GROUP  BY results.environment_id) results \
          where results.environment_id = environments.id"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def testcase_summary
    sql = "SELECT testcases.id, testcases.name, testcases.validation_id, results.pass_count, results.fail_count, results.skip_count, results.updated_at from testcases, \
        (SELECT results.testcase_id, MAX(results.updated_at) updated_at, \
             Count(CASE \
                     WHEN results.current_status = 'pass' THEN 1\
                     ELSE NULL \
                   END) AS pass_count, \
             Count(CASE \
                     WHEN results.current_status = 'fail' THEN 1 \
                     ELSE NULL \
                   END) AS fail_count, \
             Count(CASE \
                     WHEN results.current_status = 'skip' THEN 1 \
                     ELSE NULL \
                   END) AS skip_count \
        FROM  results \
        WHERE results.execution_id = #{self.id} \
        GROUP  BY results.testcase_id) results \
        where results.testcase_id = testcases.id"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def close!
    self.update(closed: true)
    self.update(closed_at: DateTime.now)
  end
end
