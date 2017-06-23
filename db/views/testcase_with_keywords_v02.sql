SELECT  testcases.id, testcases.name, testcases.validation_id, testcases.updated_at, testcases.version, testcases.token, testcases.outdated, array_agg(keywords.keyword) FROM "testcases"
  JOIN keywords_testcases ON keywords_testcases.testcase_id = testcases.id
  JOIN keywords ON keywords_testcases.keyword_id = keywords.id
GROUP BY testcases.id, testcases.name, testcases.validation_id, testcases.updated_at, testcases.version, testcases.token, testcases.outdated
