class CreateFeatureds < ActiveRecord::Migration
  def change
    create_table :featureds do |t|
      t.integer :user_id
      t.string :description
      t.boolean :live, :default => false
      t.timestamps
    end
    
    add_index :featureds, :live
    
    if Rails.env.development? && defined?(Featured)
      User.limit(4).each do |u|
        Featured.create(:user_id => u.id, :live => true)
      end
    end
  end
end
