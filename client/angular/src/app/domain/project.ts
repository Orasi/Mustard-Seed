import { TestCase } from "./testcases/testcase";
import { Keyword } from "./keyword";
import { Environment } from "./environment";
import { Execution } from "./executions/execution";


export class Project {

  constructor(
    public id: number,
    public projectName: string,
    public apiKey: string,
    public executionId: string,
    public testcases: Array<TestCase>,
    public executions: Array<Execution>,
    public keywords: Array<Keyword>,
    public environments: Array<Environment>
  ) {  }

  public static create(data: any): Project {
    if (data.testcases) {
      var testcases = [];
      for (var testcase of data.testcases) {
        testcases.push(TestCase.create(testcase));
      }
    }

    if (data.environments) {
      var environments = [];
      for (var environment of data.environments) {
        environments.push(Environment.create(environment));
      }
    }

    if (data.executions) {
      var executions = [];
      for (var execution of data.executions) {
        executions.push(Execution.create(execution));
      }
    }

    if (data.keywords) {
      var keywords = [];
      for (var keyword of data.keywords) {
        keywords.push(Keyword.create(keyword));
      }
    }

    return new Project(data.id, data.projectName, data.apiKey, data.executionId,
      testcases, executions, keywords, environments);
  }
}
