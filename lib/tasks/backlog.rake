namespace :redmine_backlog do
  desc "Reset position"
  task :reset_position => :environment do
    Version.visible
           .where(sharing: 'system')
           .where.not(status: 'closed').each do |version|
      Backlog.reset_positions version
    end
  end
end
