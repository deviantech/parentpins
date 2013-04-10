class AbortSeparateFeaturedTableApproach < ActiveRecord::Migration
  def up
    add_column :users, :featured, :boolean, :default => false
    add_column :users, :featured_bio, :text
    add_index :users, :featured
    drop_table :featureds
    
    if Rails.env.development?
      User.limit(4).each do |u|
        u.feature
      end
    end
  end

  def down
    remove_index :users, :featured
    remove_column :users, :featured
    remove_column :users, :featured_bio
    
    create_table "featureds", :force => true do |t|
      t.integer  "user_id"
      t.string   "description"
      t.boolean  "live",        :default => false
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
    end

    add_index "featureds", ["live"], :name => "index_featureds_on_live"
  end
end