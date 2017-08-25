namespace :mustard do
  desc "Setups data base and creates a default user"
  task :setup do
    begin
      Rake::Task['environment'].invoke
      Rake::Task['db:setup'].invoke
      User.create(username: 'mustard_admin', first_name: 'mustard', last_name: 'admin', company: 'mustard', admin: true, email: 'mustard@mustard.com')
    rescue
      exit 1
    else
      exit 0
    end
  end
end