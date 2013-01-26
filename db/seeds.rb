# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

%w(Expecting Infants Toddlers Kids Tweens Teens).each do |n|
  AgeGroup.create(:name => n)
end


(%w(Activities Education Health Disabilities Crafts Media Books Food Products Sports Holidays Photography Pregnancy Cuteness) + ['Parenting Advice', 'Funny / Humor']).each do |n|
  Category.create(:name => n)
end
