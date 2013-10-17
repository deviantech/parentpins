class AddCustomCroppingAbilityToCoverImage < ActiveRecord::Migration
  def change
    add_column :users, :cover_image_x, :integer
    add_column :users, :cover_image_y, :integer
    add_column :users, :cover_image_w, :integer
    add_column :users, :cover_image_h, :integer
    
    User.reset_column_information
    
    User.where('cover_image IS NOT NULL').find_each do |u|
      if u.cover_image?
        u.update_attributes(:cover_image_x => 0, :cover_image_y => 0, :cover_image_w => 1020, :cover_image_h => 160)
        u.cover_image.recreate_versions!
        u.save
      end
    end
  end
end