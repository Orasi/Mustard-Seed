class Execution < ApplicationRecord

  scope :open_execution, ->() { find_by_closed(false) }
  scope :closed, -> {where(closed: true)}

  before_save :default_name

  belongs_to :project, touch: true
  has_many :results, dependent: :destroy
  validate :active_environments_exist
  validate :active_keywords_exist

  def active_environments_exist
    return if active_environments.blank?
    env_ids = project.environments.pluck(:id)
    active_environments.each do |env|
      unless env_ids.include? env
        errors[:base] << "Environment ID #{env} is not valid"
      end
    end
  end

  def last_results_by_testcase
    r = results.select(:id, :testcase_id, :execution_id, 'results::json->0 as results').group_by{|d| d[:testcase_id]}
    results = Hash.new([])
    r.each do |key, value|
      results[key] = value.map(&:attributes)
      results[key] = results[key].map{|i| i.merge(i['results']).without('results').without('testcase_id')}
    end
    results
  end

  def active_keywords_exist
    return if active_keywords.blank?
    keyword_ids = project.keywords.pluck(:id)
    active_keywords.each do |keyword|
      unless keyword_ids.include? keyword
        errors[:base] << "Keyword ID #{keyword} is not valid"
      end
    end
  end

  def default_name
    if self.name.blank?
      self.name = "Execution: #{DateTime.now.strftime('%m/%d/%Y')}"
    end
  end

  def execution_environments
    if active_environments.blank?
      return project.environments
    else
      return Environment.where(id: active_environments)
    end
  end

  def execution_keywords
    if active_keywords.blank?
      return project.keywords
    else
      return Keyword.where(id: active_keywords)
    end
  end

  def execution_testcases
    if active_keywords.blank?
      return project.testcases
    else
      return Testcase.where(id: Testcase.joins(:keywords_testcases).where(keywords_testcases: {keyword_id: execution_keywords}).pluck(:id))
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

    return fast_testcase_summary if self.fast

    where_clause = "AND testcases.id in (#{execution_testcases.pluck(:id).join(',')})" unless active_keywords.blank?

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
      WHERE results.testcase_id = testcases.id #{active_keywords.blank? ? '' : where_clause }"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def fast_testcase_summary
    where_clause = "AND testcases.id in (#{execution_testcases.pluck(:id).join(',')})" unless active_keywords.blank?

    sql = "SELECT slow.id, slow.name, slow.validation_id, slow.updated_at, CASE
                                                                WHEN slow.fail_count > 0 THEN 'fail'
                                                                WHEN slow.fail_count = 0 AND slow.pass_count = 0 AND slow.skip_count > 0 THEN 'skip'
                                                                WHEN slow.fail_count = 0 and slow.pass_count > 0 THEN 'pass'
                                                                END as current_status
      from (SELECT testcases.id, testcases.name, testcases.validation_id, results.pass_count, results.fail_count, results.skip_count, results.updated_at from testcases, \
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
        WHERE results.testcase_id = testcases.id #{active_keywords.blank? ? '' : where_clause }) slow"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def keyword_summary

    return fast_keyword_summary if self.fast

    sql = "SELECT keywords.keyword, Count(CASE WHEN results.current_status = 'pass' THEN 1 ELSE NULL END) AS pass_count, \
                          Count(CASE WHEN results.current_status = 'fail' THEN 1 ELSE NULL END) AS fail_count, \
                          Count(CASE WHEN results.current_status = 'skip' THEN 1 ELSE NULL END) AS skip_count, \
                          Count(CASE WHEN results.current_status IS NULL THEN 1 ELSE NULL END) AS not_run_count, \
                          Count(CASE WHEN TRUE THEN 1 ELSE NULL END) AS expected_count, \
                          MAX(results.updated_at) AS updated_at
          FROM (SELECT testcases.id AS testcase_id, \
                       environments.id AS environment_id \
                FROM testcases CROSS JOIN environments \
                WHERE testcases.project_id = #{self.project_id} AND environments.project_id = #{self.project_id} AND testcases.outdated = false) testcase_envs \
          LEFT JOIN results ON testcase_envs.testcase_id = results.testcase_id AND testcase_envs.environment_id = results.environment_id AND results.execution_id = #{self.id} \
          LEFT JOIN keywords_testcases on testcase_envs.testcase_id = keywords_testcases.testcase_id \
          LEFT JOIN keywords on keywords_testcases.keyword_id = keywords.id \
          JOIN testcases on testcase_envs.testcase_id = testcases.id \
          JOIN environments on testcase_envs.environment_id = environments.id \
          JOIN executions on testcases.project_id = executions.project_id \
          WHERE executions.id = #{self.id} \
          GROUP BY keywords.keyword"

    ActiveRecord::Base.connection.select_all(sql)

  end

  def fast_keyword_summary
    sql = "SELECT counts.*, expected_count - fail_count - skip_count - pass_count not_run_count from
            (SELECT unnest(testcases.keywords) keyword, COUNT(DISTINCT(testcases.name)) AS expected_count,
            Count(CASE
              WHEN res.fail_count > 0 THEN 1
              ELSE NULL
              END) AS fail_count,
            Count(CASE
              WHEN res.fail_count = 0  AND res.pass_count = 0 AND res.skip_count > 0 THEN 1
              ELSE NULL
              END) AS skip_count,
            Count(CASE
                  WHEN res.fail_count = 0  AND res.pass_count > 0 THEN 1
                  ELSE NULL
                  END) AS pass_count
            FROM testcase_with_keywords as testcases
            FULL OUTER JOIN (
              SELECT results.testcase_id, results.execution_id,
                Count(CASE WHEN results.current_status = 'pass' THEN 1 ELSE NULL END) AS pass_count,
                Count(CASE WHEN results.current_status = 'skip' THEN 1 ELSE NULL END) AS skip_count,
                Count(CASE WHEN results.current_status = 'fail' THEN 1 ELSE NULL END) AS fail_count
              from results
              WHERE results.execution_id = #{self.id}
              GROUP BY  results.testcase_id, results.execution_id) as res on res.testcase_id = testcases.id
            GROUP BY keyword) AS counts"
    ActiveRecord::Base.connection.select_all(sql)
  end

  def close!
    self.update(closed: true)
    self.update(closed_at: DateTime.now)
  end
end
