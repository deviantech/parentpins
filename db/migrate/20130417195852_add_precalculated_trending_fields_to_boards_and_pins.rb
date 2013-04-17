class AddPrecalculatedTrendingFieldsToBoardsAndPins < ActiveRecord::Migration
  def change
    add_column :pins,   :trend_position, :integer
    add_column :boards, :trend_position, :integer
    add_index :pins,    :trend_position
    add_index :boards,  :trend_position
    add_index :pins,    :url
    rename_column :pins, :repin_count, :repins_count
  end
end