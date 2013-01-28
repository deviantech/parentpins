FactoryGirl.define do

  factory :category do
    sequence :name do |i|
      "Category #{i}"
    end
  end

  factory :age_group do
    sequence :name do |i|
      "Age Group #{i}"
    end
  end
  
  factory :user do
    sequence :username do |i|
      "testuser_#{i}"
    end
    email { "#{username}@pptest.com".downcase }
    password { SecureRandom.hex(10) }
  end
  
  factory :board do
    user
    category
    sequence :name do |i|
      "Board Number #{i}"
    end
    slug { name.gsub(/\s/, '-') }
  end
  
  factory :pin do
    user
    board
    age_group
    sequence :url do |i|
      "http://www.somesite.com/article/#{i}"
    end
    description { Faker::HipsterIpsum.words( rand(5..25) ) }
  end
  
end
