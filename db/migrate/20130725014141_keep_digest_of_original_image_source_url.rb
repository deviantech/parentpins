class KeepDigestOfOriginalImageSourceUrl < ActiveRecord::Migration
  def up
    add_column :pins, :source_url, :string
  end

  def down
    remove_column :pins, :source_url
  end
end