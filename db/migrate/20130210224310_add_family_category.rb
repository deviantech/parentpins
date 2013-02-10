class AddFamilyCategory < ActiveRecord::Migration
  def up
    Category.create(:name => "Family")
  end

  def down
  end
end
