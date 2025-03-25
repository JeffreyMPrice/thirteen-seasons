require 'rails_helper'

RSpec.feature "WeatherForm", type: :feature do
  scenario "User submits address to get weather" do
    visit root_path

    fill_in "Address:", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Weather for 123 Main St")
  end

  scenario "User submits form without address" do
    visit root_path

    fill_in "Address:", with: ""
    click_button "Get Weather"

    expect(page).to have_content("Address cannot be blank.")
  end
end
