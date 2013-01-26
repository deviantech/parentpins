class CategoryNameIndex < ActiveRecord::Migration
  def up
    begin
      add_index :categories, :name, :unique => true
    rescue
      nil
    end
    
    connection.execute("truncate table categories")
    connection.execute("truncate table age_groups")
  end

  def down
    remove_index :categories, :name
  end
end