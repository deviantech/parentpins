class AddBoardPositions < ActiveRecord::Migration
  def up
    add_column :boards, :position, :integer
    remove_index "boards", ["user_id", "name"]
    add_index "boards", ["user_id", "position"]
    
    Board.reset_column_information
    
    User.find_each do |u|
      u.boards.each do |b|
        b.update_attribute :position, u.boards.index(b) + 1
      end
    end    
  end

  def down
    remove_index "boards", ["user_id", "position"]
    add_index "boards", ["user_id", "name"]
    remove_column :boards, :position    
  end
end