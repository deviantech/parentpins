class TestingMigrationsOnDeploy < ActiveRecord::Migration
  def change
    puts "Sleeping for 10 seconds"
    sleep 10
  end
end
