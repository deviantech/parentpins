class MakeCommentsPolymorphic < ActiveRecord::Migration
  def up
    add_column :comments, :commentable_type, :string
    remove_index :comments, :pin_id
    rename_column :comments, :pin_id, :commentable_id
    
    Comment.reset_column_information
    
    Comment.update_all ['commentable_type=?', 'Pin']
    
    add_index :comments, [:commentable_type, :commentable_id]
    add_column :boards, :comments_count, :integer, :default => 0
  end

  def down
    remove_column :boards, :comments_count
    remove_column :comments, :commentable_type, :string
    remove_index :comments, [:commentable_type, :commentable_id]
    rename_column :comments, :commentable_id, :pin_id
    
    Comment.reset_column_information
    
    add_index :comments, :pin_id
  end
end