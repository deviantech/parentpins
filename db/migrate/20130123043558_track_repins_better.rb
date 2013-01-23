class TrackRepinsBetter < ActiveRecord::Migration
  def up
    add_column :pins, :repinned_from_id, :integer
    add_column :pins, :repin_count, :integer, :default => 0
  end

  def down
    remove_column :pins, :repinned_from_id
    remove_column :pins, :repin_count
  end
end