class AddBoardImages < ActiveRecord::Migration
  def up
    add_column :boards, :cover, :string
  end

  def down
    remove_column :boards, :cover
  end
end