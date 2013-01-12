class CounterCacheComments < ActiveRecord::Migration
  def up
    add_column :pins, :comments_count, :integer, :default => 0
  end

  def down
    remove_column :pins, :comments_count
  end
end