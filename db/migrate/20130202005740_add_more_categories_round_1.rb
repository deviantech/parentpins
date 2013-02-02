class AddMoreCategoriesRound1 < ActiveRecord::Migration
  def up
    %w(Travel Decor Style).each do |n|
      Category.find_by_name(n) || Category.create(:name => n)
    end
    
    Category.find_by_name('Funny / Humor').update_attribute(:name, 'Humor')
    Category.find_by_name('Holidays').update_attribute(:name, 'Holidays and Parties')
    Category.find_by_name('Parenting Advice').update_attribute(:name, 'Advice')
    remove_index :boards, :user_id
    add_index :boards, [:user_id, :name]
  end

  def down
  end
end
