class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.integer :user_id
      t.string  :source
      t.integer :attempted, :default => 0
      t.integer :completed, :default => 0
      t.string :user_agent
      t.timestamps
    end
    
    add_column :pins, :import_id, :integer
  end
end