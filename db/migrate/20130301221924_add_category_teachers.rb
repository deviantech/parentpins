class AddCategoryTeachers < ActiveRecord::Migration
  def up
    Category.create(:name => 'Teachers') if Category.where(:name => 'Teachers').first.blank?
  end

  def down
  end
end
