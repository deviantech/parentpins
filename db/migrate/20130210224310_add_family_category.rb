class AddFamilyCategory < ActiveRecord::Migration
  def up
    # Actually age group is wanted, not Category
    AgeGroup.create(:name => "Family")
  end

  def down
  end
end
