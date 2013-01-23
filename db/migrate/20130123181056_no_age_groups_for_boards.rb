class NoAgeGroupsForBoards < ActiveRecord::Migration
  def up
    remove_column :boards, :age_group_id
  end

  def down
    add_column :boards, :age_group_id, :integer
  end
end