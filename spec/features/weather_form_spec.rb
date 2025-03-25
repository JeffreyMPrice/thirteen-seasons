require 'rails_helper'

RSpec.feature "WeatherForm", type: :feature do
  scenario "User submits address to get weather" do
    allow_any_instance_of(GeolocationService).to receive(:geolocate).and_return(
      Address.new(
        plain_text: "123 Main St",
        latitude: 37.7749,
        longitude: -122.4194,
        formatted_address: "123 Main St, San Francisco, CA 94103, USA"
      )
    )

    visit root_path

    fill_in "Address:", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Weather for 123 Main St, San Francisco, CA 94103, USA")
  end

  scenario "User submits form without address" do
    visit root_path

    fill_in "Address:", with: ""
    click_button "Get Weather"

    expect(page).to have_content("Address cannot be blank.")
  end
end
