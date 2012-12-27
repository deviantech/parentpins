class CreateBoards < ActiveRecord::Migration
  def change    
    create_table :boards do |t|
      t.string :name
      t.text :description
      t.integer :category_id
      t.integer :age_group_id
      t.integer :user_id

      t.timestamps
    end
    
    add_index :boards, :user_id
    add_index :boards, :category_id
    add_index :boards, :age_group_id
  end
end
