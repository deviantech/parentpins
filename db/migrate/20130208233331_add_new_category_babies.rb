class AddNewCategoryBabies < ActiveRecord::Migration
  def up
    Category.create(:name => "Babies")
  end

  def down
  end
end