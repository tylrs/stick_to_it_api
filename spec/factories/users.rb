FactoryBot.define do
  factory :user, aliases: %i[creator sender recipient] do
    name { Faker::Name.name }
    username { Faker::Internet.username }
    email { Faker::Internet.safe_email }
    password { "123456" }
    password_confirmation { "123456" }
  end
end
