class AddCategoryTeachers < ActiveRecord::Migration
  def up
    Category.create(:name => 'Teachers')
  end

  def down
  end
end
