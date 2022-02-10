require 'rails_helper'

RSpec.describe User, type: :model do
  # before(:all) do
  #   @user = User.create(name: "Brenda Johnson", 
  #                       username: "brenjo1", 
  #                       email: "brendajohnson@example.com", 
  #                       password: "123456", 
  #                       password_confirmation: "123456")
  # end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
    it { should have_secure_password(:password) }
  end

  describe "relationships" do
    it { should have_many(:habits) }
  end

end
