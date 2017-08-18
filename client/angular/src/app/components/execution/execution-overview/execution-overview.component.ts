import { Component, ViewChild, ElementRef, Input, OnChanges, SimpleChanges } from '@angular/core';
import { ExecutionStatus } from "../../../domain/executions/execution-status";
import Chart from 'chart.js';


@Component({
  selector: 'app-execution-overview',
  templateUrl: './execution-overview.component.html'
})
export class ExecutionOverviewComponent implements OnChanges {

  @Input() executionStatus: ExecutionStatus;
  @ViewChild('executionChart') chart: ElementRef;

  pass: Summary;
  fail: Summary;
  skip: Summary;
  notRun: Summary;

  constructor() { }

  ngOnChanges(changes: SimpleChanges) {
    if (changes.executionStatus.currentValue) {
      this.executionStatus = changes.executionStatus.currentValue;

      let passCount = this.executionStatus.passes.length;
      let failCount = this.executionStatus.fails.length;
      let skipCount = this.executionStatus.skips.length;
      let notRunCount = this.executionStatus.notRuns.length;
      let total = passCount + failCount + skipCount + notRunCount;

      this.pass = { count: this.executionStatus.passes.length, percent: (passCount / total * 100)};
      this.fail = { count: this.executionStatus.fails.length, percent: (failCount / total * 100)};
      this.skip = { count: this.executionStatus.skips.length, percent: (skipCount / total * 100)};
      this.notRun = { count: this.executionStatus.notRuns.length, percent: (notRunCount / total * 100)};
      this.setDoughNutChart();
    }
  }

  setDoughNutChart() {
    let chartCtx = this.chart.nativeElement.getContext('2d');
    chartCtx.canvas.width = 200;
    chartCtx.canvas.height = 200;

    let data = {
      labels: [
        "Pass",
        "Fail",
        "Skip",
        "Not Run"
      ],
      datasets: [{
          data: [this.pass.count, this.fail.count, this.skip.count, this.notRun.count],
          backgroundColor: [ "#1abc9c", "#e74c3c", "#e7ba0f" ]
        }]
    };

    let options = {
      legend: { display: false },
      responsive: true,
      maintainAspectRatio: false,
      tooltips: {
        callbacks: {
          label: function(tooltipItem, data) {
            let dataset = data.datasets[tooltipItem.datasetIndex];

            let total = dataset.data.reduce(function(previousValue, currentValue, currentIndex, array) {
              return previousValue + currentValue;
            });

            let currentValue = dataset.data[tooltipItem.index];
            let precentage = Math.floor(((currentValue / total) * 100) + 0.5);
            return precentage + "%";
          }
        }
      }
    };

    let current_chart = new Chart(chartCtx, {
      type: 'doughnut',
      data: data,
      options: options
    });
  }
}


interface Summary {
  count: number
  percent: number
}
