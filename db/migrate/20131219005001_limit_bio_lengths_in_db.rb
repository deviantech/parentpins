class LimitBioLengthsInDb < ActiveRecord::Migration
  def change
    change_column :users, :bio, :string, :limit => 400
    change_column :users, :featured_bio, :string, :limit => 400
  end
end