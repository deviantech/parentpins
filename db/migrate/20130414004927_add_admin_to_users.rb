class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, :default => false
    User.first && User.first.update_attribute(:admin, true)
  end
end
