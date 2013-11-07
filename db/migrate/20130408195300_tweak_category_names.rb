class TweakCategoryNames < ActiveRecord::Migration
  def up
    Category.where(:name => 'Holidays and Parties').first.try(:update_attribute, :name, 'Holidays & Parties')
  end

  def down
    Category.where(:name => 'Holidays & Parties').first.try(:update_attribute, :name, 'Holidays and Parties')
  end
end
