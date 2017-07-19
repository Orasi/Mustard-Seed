import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HttpModule } from '@angular/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { AuthenticationGuard } from './guards/auth.guard';
import { AdministrationGuard } from './guards/administration.guard';

import { UserService } from "./services/user.service";

import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { NavBarComponent } from './components/nav-bar/nav-bar.component';
import { RegisterComponent } from './components/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { RegisterFormComponent } from './components/register/register-form/register-form.component';
import { LoginFormComponent } from './components/login/\/login-form/login-form.component';
import { ForgotPasswordFormComponent } from './components/forgot-password/forgot-password-form/forgot-password-form.component';


const appRoutes: Routes = [
  { path: 'register', component: RegisterComponent, canActivate: [AdministrationGuard] },
  { path: 'login', component: LoginComponent },
  { path: '', component: DashboardComponent, canActivate: [AuthenticationGuard] }
];


@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    ForgotPasswordComponent,
    NavBarComponent,
    LoginFormComponent,
    RegisterFormComponent,
    RegisterComponent,
    DashboardComponent,
    ForgotPasswordFormComponent
  ],
  imports: [
    BrowserModule,
    HttpModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule.forRoot(
      appRoutes,
      { enableTracing: true } // <-- debugging purposes only
    )
  ],
  providers: [AuthenticationGuard, AdministrationGuard, UserService],
  bootstrap: [AppComponent]
})

export class AppModule { }
