class SupportAdvancedUploadOptions < ActiveRecord::Migration
  def change
    add_column :users, :avatar_token, :string
    add_column :users, :cover_image_token, :string
    add_column :pins,  :image_token, :string
    add_column :pins,  :image_original_filename, :string
    rename_column :pins, :source_url, :source_image_url

    Pin.reset_column_information
    Pin.find_each do |p|
      p.update_attribute :image_original_filename, p['image']
    end
    
  end
end