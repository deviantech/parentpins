class TweakCategoryNames < ActiveRecord::Migration
  def up
    Category.find_by_name('Holidays and Parties').update_attribute(:name, 'Holidays & Parties')
  end

  def down
    Category.find_by_name('Holidays & Parties').update_attribute(:name, 'Holidays and Parties')
  end
end
