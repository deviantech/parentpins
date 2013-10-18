class AddCustomCroppingAbilityToAvatar < ActiveRecord::Migration
  def change
    add_column :users, :avatar_x, :integer
    add_column :users, :avatar_y, :integer
    add_column :users, :avatar_w, :integer
    add_column :users, :avatar_h, :integer

    User.reset_column_information
    
    User.where('avatar IS NOT NULL').find_each do |u|
      if u.avatar?
        u.update_attributes(:avatar_x => 0, :avatar_y => 0, :avatar_w => 120, :avatar_h => 120)
        u.avatar.recreate_versions!
        u.save
      end
    end
  end
end