

# Mustard
Ruby on Rails based multi-environment test results server.  Mustard collects test results from closely related tests (IE Cross Browser or Mobile Testing on Multiple Device) and groups them for easy analysis.  The Mustard-Seed is the backend server and can be combined with [Mustard-Dijon](https://github.com/Orasi/Mustard-Dijon) for viewing test results easily.

# Getting Started
## Requirements Before Starting
*   Ruby version 2.3 or later
*   PostgresSQL database > 9.0

Instructions for installing these prerequisetes can be found at [RubyLang.org](https://www.ruby-lang.org/en/documentation/installation/) and [PostgresSQL.org](https://wiki.postgresql.org/wiki/Detailed_installation_guides).  Any method of installing Ruby will work, but using RVM or RBenv is highly recommended. **Mustard is developed and used on various Linux distrubutions as well as MacOS.  No testing has been done in Windows and additional configuration may be required**

## Setup Mustard-Seed
### Clone and Install
Clone this repo and and change directory in to the cloned directory.  First we will need to install all the dependencies for Mustard from RubyGems.  This is done using the Bundle tool packaged with Ruby.  If not already installed you can install bundler with the following command.

`gem install bundler`

After installing Bundler we can initiate the install of all required gem dependencies

`bundle install`

This command reads a list of the dependencies found in the [Gemfile](Gemfile) and installs them.  If any of the dependencies do not install succesfully you are likely missing the RubyDevKit for your installed version of Ruby.  This installation will vary from system to system, but should be easily findable on Google.

### Setup Database
We now need to configure Mustard to allow it to manage our PostgresSQL database.  This configuration is found [<MustardRoot>/config/database.yml](config/database.yml) **PostgresSQL is the only supported database for Mustard.  We make use of several Postgres specific functions that will not working in other databases**

This guide will be walking through setting up the Development environment, but configuring anyother environment is essentially the same in the database.yml file.  

In database.yml find the development section and change the values for host, username, and password to the correct values for your PostgresSQL setup.  Host should contain the IP address of the PostgresSQL server, or localhost if the database and Mustard are running on the same server.  Once necessary changes have been made you may save and close this file.

After configuring the database information we can now create the database that will be used.  This can be done with the following command.

`rake db:create`

and then

`rake db:migrate`

These commands will create the database and and all the tables that are needed for Mustard.

### Adding a User
By default Mustard does not have any users configured and atleast one will need to be added in the Rails console to allow access.  You can access the Rails console by running the following command from the Mustard root directory.

`rails console`

And we can create a user in the console with the following command.

`User.create(first_name: '', last_name: '', username: '', password: '', password_confirmation: '', company: '', admin: true)`

Where all the relevant values have been filled in.  **Usernames should always be a valid email address so we can send Reset Password Emails.**

### Starting Mustard
The Mustard server should be able to be started with the following command.

`rails server -p 8080`

This command starts the application listening on port 8080.  *This configuration is not sufficient for production setup and will need a real webserver.  We use Nginx in these cases, but many options are available.  Google 'Setup Rails Production Apps' for more information.*  You should now be able to check that the application is working.  Navigating the http://localhost:8080/docs should display the documentation for Mustard-Seed and all the commands available throught he API.

We can also validate that the application is up and running via a CURL command to login in.  

`curl -X POST -H "Content-Type: application/json"  -d '{
	"username": "INSERT USERNAME HERE",
	"password": "INSERT PASSWORD HERE"
}' "http://localhost:8080/authenticate"`

This command should return information about the user and a UserToken that will be needed for all other API calls.

# Orasi Software Inc
Orasi is a software and professional services company focused on software quality testing and management.  As an organization, we are dedicated to best-in-class QA tools, practices and processes. We are agile and drive continuous improvement with our customers and within our own business.

# License
Licensed under [BSD License](/License)
