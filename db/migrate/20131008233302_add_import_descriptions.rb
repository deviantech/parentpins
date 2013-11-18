class AddImportDescriptions < ActiveRecord::Migration
  def change
    add_column :age_groups, :description, :string
    AgeGroup.reset_column_information

    groups = {
      'Expecting' => 'for pregnancy or planning for kids.',
      'Infants' => 'for babies too young to walk.',
      'Toddlers' => 'for those beginning to walk up to about 3 years old.',
      'Kids' => 'for children under age 10.',
      'Tweens' => 'for kids ten to twelve.',
      'Teens' => 'for teenagers.',
      'Family' => 'for the whole family. Not age specific.'
    }
    
    groups.each do |name, desc|
      g = AgeGroup.find_or_create_by(:name => name)
      g.update_attribute :description, desc
    end
  end
end