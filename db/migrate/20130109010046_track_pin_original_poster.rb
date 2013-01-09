class TrackPinOriginalPoster < ActiveRecord::Migration
  def up
    add_column :pins, :original_poster_id, :integer
  end

  def down
    remove_column :pins, :original_poster_id
  end
end