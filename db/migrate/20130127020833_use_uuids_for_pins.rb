class UseUuidsForPins < ActiveRecord::Migration
  def up
    add_column :pins, :uuid, :string, :limit => 36
    add_index :pins, :uuid, :unique => true
    
    Pin.reset_column_information
    
    Pin.all.each do |p|
      p.send(:uuid)
      p.save
    end
  end

  def down
    remove_column :pins, :uuid
    remove_index :pins, :uuid, :unique => true
  end
end