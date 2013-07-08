class FixCounterCacheValues < ActiveRecord::Migration
  def change
    Board.find_each do |b|
      Board.update_all ['pins_count=?', b.pins.count], ['id=?', b.id]
    end
  end
end
