class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.text :body
      t.string :email
      t.integer :user_id
      t.string :user_agent

      t.timestamps
    end
  end
end
