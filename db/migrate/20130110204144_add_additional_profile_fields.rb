class AddAdditionalProfileFields < ActiveRecord::Migration
  def up
    add_column :users, :kids, :integer
    add_column :users, :bio, :text
  end

  def down
    remove_column :users, :kids
    remove_column :users, :bio
  end
end