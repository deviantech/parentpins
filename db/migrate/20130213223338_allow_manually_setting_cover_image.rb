class AllowManuallySettingCoverImage < ActiveRecord::Migration
  def up
    add_column :boards, :cover_source_id, :integer
  end

  def down
    remove_column :boards, :cover_source_id
  end
end