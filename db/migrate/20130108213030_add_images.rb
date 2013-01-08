class AddImages < ActiveRecord::Migration
  def up
    add_column :pins, :image, :string
    add_column :users, :avatar, :string
  end

  def down
    remove_column :pins, :image
    remove_column :users, :avatar
  end
end