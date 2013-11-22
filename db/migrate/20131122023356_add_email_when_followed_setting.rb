class AddEmailWhenFollowedSetting < ActiveRecord::Migration
  def change
    add_column :users, :email_on_new_follower, :boolean, :default => true
  end
end