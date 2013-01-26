class CategoryNameIndex < ActiveRecord::Migration
  def up
    add_index :categories, :name, :unique => true
    
    Category.delete_all
    AgeGroup.delete_all
    
    connection.execute("truncate table categories")
    connection.execute("truncate table age_groups")
    
    Rake::Task['db:seed'].invoke()
  end

  def down
    remove_index :categories, :name
  end
end