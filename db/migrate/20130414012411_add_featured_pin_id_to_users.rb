class AddFeaturedPinIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :featured_pin_id, :integer
  end
end
