class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.integer :user_id
      t.integer :pin_id

      t.timestamps
    end
    
    add_index :comments, :user_id
    add_index :comments, :pin_id
  end
end
