class AllowLongerUrls < ActiveRecord::Migration
  def change
    change_column :pins, :url, :string, :limit => 1024
  end
end