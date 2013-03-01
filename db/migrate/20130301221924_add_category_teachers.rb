class AddCategoryTeachers < ActiveRecord::Migration
  def up
    Category.create(:name => 'Teachers') if Category.find_by_name('Teachers').blank?
  end

  def down
  end
end
