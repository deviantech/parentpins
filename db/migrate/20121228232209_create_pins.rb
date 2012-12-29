class CreatePins < ActiveRecord::Migration
  def change
    create_table :pins do |t|
      t.string :name
      t.string :kind
      t.string :url
      t.decimal :price,            :precision => 10, :scale => 2
      t.integer :user_id
      t.integer :board_id
      t.integer :category_id
      t.integer :age_group_id
      t.integer :via_id

      t.timestamps
    end
    add_index :pins, :user_id
    add_index :pins, :via_id
    add_index :pins, :board_id
    add_index :pins, :category_id
    add_index :pins, :age_group_id
  end
end