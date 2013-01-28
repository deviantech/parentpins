class CounterCacheBoardPinCount < ActiveRecord::Migration
  def up
    add_column :boards, :pins_count, :integer, :default => 0
    
    Board.reset_column_information
    
    Board.find_each do |b|
      Board.update_all ['pins_count=?', b.pins.count], ['id=?', b.id]
    end
  end

  def down
    remove_column :boards, :pin_count
  end
end