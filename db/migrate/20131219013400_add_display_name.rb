class AddDisplayName < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, :limit => 40
    
    User.find_each do |u|
      next unless u.username.length > 40
      puts "Truncating #{u.id}'s username from #{u.username}"
      u.username = u.username[0,40]
      u.save
    end
    
    change_column :users, :username, :string, :limit => 40
  end
end