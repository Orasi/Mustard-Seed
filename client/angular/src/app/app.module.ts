import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HttpModule } from '@angular/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { NavBarComponent } from './components/nav-bar/nav-bar.component';
import { LoginFormComponent } from './components/login/\/login-form/login-form.component';
import { RegisterFormComponent } from './components/register/register-form/register-form.component';
import { RegisterComponent } from './components/register/register.component';


const appRoutes: Routes = [
  { path: 'register', component: RegisterComponent },
  { path: '', component: LoginComponent }
  //{ path: '**', component: PageNotFoundComponent }
];


@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    ForgotPasswordComponent,
    NavBarComponent,
    LoginFormComponent,
    RegisterFormComponent,
    RegisterComponent
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
  providers: [],
  bootstrap: [AppComponent]
})

export class AppModule { }
