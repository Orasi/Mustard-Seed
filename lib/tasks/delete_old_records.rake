# lib/tasks/delete_old_records.rake
namespace :delete do
  desc 'Delete records older than 14 days'
  task :old_records => :environment do
    Execution.where('created_at < ? and closed=true', 14.days.ago).each do |model|
      begin
        model.destroy
        puts 'Deleted'
      rescue
        puts 'Could not be deleted'
      end

    end
  end
end