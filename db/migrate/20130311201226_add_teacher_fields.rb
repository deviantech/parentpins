class AddTeacherFields < ActiveRecord::Migration
  def up
    add_column :users, :teacher,          :boolean, :default => false
    add_column :users, :teacher_grade,    :string
    add_column :users, :teacher_subject,  :string
  end

  def down
    remove_column :users, :teacher   
    remove_column :users, :teacher_grade 
    remove_column :users, :teacher_subject
  end
end