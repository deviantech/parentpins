class AddMoreCategoriesRound1 < ActiveRecord::Migration
  def up
    %w(Travel Decor Style).each do |n|
      Category.where(:name => n).first || Category.create(:name => n)
    end
    
    Category.where(:name => 'Funny / Humor').first.try(:update_attribute, :name, 'Humor')
    Category.where(:name => 'Holidays').first.try(:update_attribute, :name, 'Holidays and Parties')
    Category.where(:name => 'Parenting Advice').first.try(:update_attribute, :name, 'Advice')
    remove_index :boards, :user_id
    add_index :boards, [:user_id, :name]
  end

  def down
  end
end
