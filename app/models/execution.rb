class Execution < ApplicationRecord

  default_scope{ where(deleted: [false, nil])}
  scope :open_execution, ->() { find_by_closed(false) }

  belongs_to :project
  has_many :results, dependent: :destroy


  def environment_summary
    sql = "SELECT environments.id, environments.uuid, results.pass_count, results.fail_count, results.skip_count from environments, \
          (SELECT results.environment_id, \
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
          WHERE results.execution_id = #{11} \
          GROUP  BY results.environment_id) results \
          where results.environment_id = environments.id"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def testcase_summary
    sql = "SELECT testcases.id, testcases.validation_id, results.pass_count, results.fail_count, results.skip_count from testcases, \
        (SELECT results.testcase_id, \
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
        WHERE results.execution_id = #{11} \
        GROUP  BY results.testcase_id) results \
        where results.testcase_id = testcases.id"

    ActiveRecord::Base.connection.select_all(sql)

  end
end
