class AddSlugsForBoards < ActiveRecord::Migration
  def up
    add_column :boards, :slug, :string
    add_index :boards, :slug
  end

  def down
    remove_index :boards, :slug
    remove_column :boards, :slug, :string
  end
end