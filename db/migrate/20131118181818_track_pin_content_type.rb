class TrackPinContentType < ActiveRecord::Migration
  def change
    add_column :pins, :image_v222_content_type, :string
  end
end