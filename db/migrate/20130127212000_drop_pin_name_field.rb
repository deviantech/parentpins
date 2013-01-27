class DropPinNameField < ActiveRecord::Migration
  def up
    remove_column :pins, :name
  end

  def down
    add_column :pins, :name, :string
  end
end