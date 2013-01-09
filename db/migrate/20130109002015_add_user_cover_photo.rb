class AddUserCoverPhoto < ActiveRecord::Migration
  def up
    add_column :users, :cover_image, :string
  end

  def down
    remove_column :users, :cover_image
  end
end