class CreatePins < ActiveRecord::Migration
  def change
    create_table :pins do |t|
      t.string :name
      t.string :kind
      t.string :url
      t.decimal :price
      t.integer :user_id
      t.integer :board_id
      t.integer :category_id
      t.integer :age_group_id

      t.timestamps
    end
  end
end
