class AddPinFields < ActiveRecord::Migration
  def up
    add_column :pins, :description, :string
  end

  def down
    remove_column :pins, :description, :string
  end
end