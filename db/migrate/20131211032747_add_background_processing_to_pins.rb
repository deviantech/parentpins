class AddBackgroundProcessingToPins < ActiveRecord::Migration
  def change
    add_column :pins, :image_tmp, :string
  end
end