class AddSocialMediaLinks < ActiveRecord::Migration
  def up
    add_column :users, :facebook_account, :string
    add_column :users, :twitter_account, :string
  end

  def down
    remove_column :users, :facebook_account, :string
    remove_column :users, :twitter_account, :string
  end
end