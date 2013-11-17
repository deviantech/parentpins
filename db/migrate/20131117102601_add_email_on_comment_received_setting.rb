class AddEmailOnCommentReceivedSetting < ActiveRecord::Migration
  def change
    add_column :users, :email_on_comment_received, :boolean, :default => true
  end
end