namespace :weights do
  task :update => :environment do
    User.all.each(&:update_weights!)
  end
end
