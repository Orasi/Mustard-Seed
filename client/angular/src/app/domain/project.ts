import { TestCase } from "./testcases/testcase";
import { Keyword } from "./keyword";
import { Environment } from "./environment";
import { Execution } from "./executions/execution";


export class Project {

  constructor(
    public id: number,
    public name: string,
    public apiKey: string,
    public executionId: string,
    public testcases: Array<TestCase>,
    public executions: Array<Execution>,
    public keywords: Array<Keyword>,
    public environments: Array<Environment>
  ) {  }

  public static create(data: any): Project {
    let testcases = [];
    if (data.testcases) {
      for (let testcase of data.testcases) {
        testcases.push(TestCase.create(testcase));
      }
    }

    let environments = [];
    if (data.environments) {
      for (let environment of data.environments) {
        environments.push(Environment.create(environment));
      }
    }

    let executions = [];
    if (data.executions) {
      for (let execution of data.executions) {
        executions.push(Execution.create(execution));
      }
    }

    let keywords = [];
    if (data.keywords) {
      for (let keyword of data.keywords) {
        keywords.push(Keyword.create(keyword));
      }
    }

    return new Project(data.id, data.project_name, data.api_key, data.execution_id,
      testcases, executions, keywords, environments);
  }
}
