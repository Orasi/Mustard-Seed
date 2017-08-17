import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HttpModule } from '@angular/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { Select2Module } from 'ng2-select2';

import { DropzoneModule } from 'ngx-dropzone-wrapper';
import { DropzoneConfigInterface } from 'ngx-dropzone-wrapper';

import { AuthenticationGuard } from './guards/auth.guard';
import { AdministrationGuard } from './guards/administration.guard';

import { UserService } from "./services/user.service";
import { ProjectService } from "./services/project.service";
import { TeamService } from "./services/team.service";
import { ExecutionService } from "./services/execution.service";

import { ForgotPasswordFormComponent } from './components/forgot-password/forgot-password-form/forgot-password-form.component';
import { LoginFormComponent } from './components/login/\/login-form/login-form.component';
import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { NavBarComponent } from './components/nav-bar/nav-bar.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { HeaderComponent } from './components/header/header.component';
import { ExecutionStatusComponent } from './components/execution/execution-status/execution-status.component';
import { ExecutionOverviewComponent } from './components/execution/execution-overview/execution-overview.component';
import { ProjectListComponent } from './components/project/project-list/project-list.component';
import { AddProjectComponent } from './components/project/project-list/add-project/add-project.component';
import { TeamListComponent } from './components/team/team-list/team-list.component';
import { AddTeamComponent } from './components/team/add-team/add-team.component';
import { TeamUserListComponent } from './components/team/team-user-list/team-user-list.component';
import { AddTeamMemberComponent } from './components/team/team-user-list/add-team-member/add-team-member.component';
import { TeamComponent } from './components/team/team.component';
import { ProjectComponent } from './components/project/project.component';
import { UsersComponent } from './components/users/users.component';
import { AddUserComponent } from './components/users/add-user/add-user.component';
import { TestcasesComponent } from './components/project/testcases/testcases.component';
import { KeywordsComponent } from './components/project/keywords/keywords.component';
import { ReportsComponent } from './components/reports/reports.component';
import { EditProjectComponent } from './components/project/edit-project/edit-project.component';
import { EnvironmentsComponent } from './components/project/environments/environments.component';
import { ExecutionsComponent } from './components/project/executions/executions.component';
import { TeamProjectListComponent } from './components/team/team-project-list/team-project-list.component';
import { TeamAddExistingProjectComponent } from './components/team/team-project-list/team-add-existing-project/team-add-existing-project.component';
import { EditTeamComponent } from './components/team/edit-team/edit-team.component';
import { ImportTestcasesComponent } from './components/project/testcases/import-testcases/import-testcases.component';


const appRoutes: Routes = [
  { path: 'forgot-password', component: ForgotPasswordComponent },
  { path: 'login', component: LoginComponent },
  { path: '', component: DashboardComponent, canActivate: [AuthenticationGuard],
    children: [
      { path: 'projects/:id', component: ProjectComponent },
      { path: 'teams/:id', component: TeamComponent },
      { path: 'projects', component: ProjectListComponent },
      { path: 'users', component: UsersComponent }
    ]
  }
];


const DROPZONE_CONFIG: DropzoneConfigInterface = {
  url: '/projects/:id/parse',
  maxFilesize: 100,
  acceptedFiles: 'application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
};


@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    ForgotPasswordComponent,
    NavBarComponent,
    LoginFormComponent,
    DashboardComponent,
    ForgotPasswordFormComponent,
    HeaderComponent,
    ExecutionStatusComponent,
    ExecutionOverviewComponent,
    ProjectListComponent,
    AddProjectComponent,
    TeamListComponent,
    AddTeamComponent,
    TeamUserListComponent,
    AddTeamMemberComponent,
    TeamComponent,
    ProjectComponent,
    UsersComponent,
    AddUserComponent,
    TestcasesComponent,
    KeywordsComponent,
    ReportsComponent,
    EditProjectComponent,
    EnvironmentsComponent,
    ExecutionsComponent,
    TeamProjectListComponent,
    TeamAddExistingProjectComponent,
    EditTeamComponent,
    ImportTestcasesComponent
  ],
  imports: [
    BrowserModule,
    HttpModule,
    FormsModule,
    ReactiveFormsModule,
    Select2Module,
    RouterModule.forRoot(
      appRoutes,
      { enableTracing: true } // <-- debugging purposes only
    ),
    DropzoneModule.forRoot(DROPZONE_CONFIG)
  ],
  providers: [ AuthenticationGuard, AdministrationGuard, UserService, ProjectService, TeamService, ExecutionService ],
  bootstrap: [ AppComponent ]
})

export class AppModule { }
