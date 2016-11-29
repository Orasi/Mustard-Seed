

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



# Orasi Software Inc
Orasi is a software and professional services company focused on software quality testing and management.  As an organization, we are dedicated to best-in-class QA tools, practices and processes. We are agile and drive continuous improvement with our customers and within our own business.

# License
Licensed under [BSD License](/License)
