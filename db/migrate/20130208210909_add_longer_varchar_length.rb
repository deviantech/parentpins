class AddLongerVarcharLength < ActiveRecord::Migration
  def up
    change_column :pins, :description, :string, :limit => 1024
  end

  def down
    change_column :pins, :description, :string, :limit => 255
  end
end