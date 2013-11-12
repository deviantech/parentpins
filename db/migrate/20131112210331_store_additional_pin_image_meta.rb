class StoreAdditionalPinImageMeta < ActiveRecord::Migration
  def change
    add_column :pins, :image_v222_width, :integer
    add_column :pins, :image_average_color, :string
  end
end