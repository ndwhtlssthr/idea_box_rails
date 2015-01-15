require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  attr_reader :user

  def setup
    @user = User.create(username: "example", password: "password")
    visit root_url
  end

  test 'a user can login' do
    fill_in "session[username]", with: "example"
    fill_in "session[password]", with: "password"
    click_link_or_button "Login"
    within("#banner") do
      assert page.has_content?("Welcome, example")
    end
  end

  test 'an unregistered user can not login' do
    click_link_or_button "Login"
    within("#flash_errors") do
      assert page.has_content?("Invalid Username or Password")
    end
  end

  test 'a user sees their idea on their main page' do
    @idea = Idea.create(title: "Great Idea", description: "Such a good idea...", user_id: user.id)
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    visit user_path(user)
    within("#ideas") do
      assert page.has_content?("Great Idea")
      assert page.has_content?("Such a good idea...")
    end
  end

  test 'a user can logout' do
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    click_link_or_button "Logout"
    within("#flash_notice") do
      assert page.has_content?("Logout successful")
    end
  end
end
