class TrackIfSeenBookmarkletMessage < ActiveRecord::Migration
  def up
    add_column :users, :got_bookmarklet, :boolean, :default => false
  end

  def down
    remove_column :users, :got_bookmarklet
  end
end