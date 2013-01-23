class TrackPinSourceUrl < ActiveRecord::Migration
  def up
    add_column :pins, :via_url, :string
  end

  def down
    remove_column :pins, :via_url
  end
end