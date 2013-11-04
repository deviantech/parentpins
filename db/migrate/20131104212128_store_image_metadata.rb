class StoreImageMetadata < ActiveRecord::Migration
  def change
    add_column :pins, :image_v222_height, :integer
  end
end