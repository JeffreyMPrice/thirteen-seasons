require 'rails_helper'

RSpec.feature "WeatherForm", type: :feature do
  let(:address_text) { "123 Main St" }
  let(:geolocated_address) do
    Address.new(
      plain_text: address_text,
      latitude: 37.7749,
      longitude: -122.4194,
      formatted_address: "#{address_text}, San Francisco, CA 94103, USA"
    )
  end
  let(:weather_data) do
    Weather.new(
      temperature: 46.4,
      dewpoint: 35.6,
      wind_direction: 270,
      wind_speed: 7.56,
      barometric_pressure: 102170,
      visibility: 16090,
      relative_humidity: 65.848771416258,
    )
  end
  let(:weather_service) { instance_double(WeatherService) }
  let(:geolocation_service) { instance_double(GeolocationService) }

  before(:each) do
    allow(WeatherService).to receive(:new).and_return(weather_service)
    allow(GeolocationService).to receive(:new).and_return(geolocation_service)
    allow(geolocation_service).to receive(:geolocate).and_return(geolocated_address)
    allow(weather_service).to receive(:current_weather).with(geolocated_address.latitude, geolocated_address.longitude).and_return(weather_data)
  end

  scenario "User submits address to get weather" do
    visit root_path

    fill_in "Address:", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Current Weather\nTemperature: 46.4 °F\nDewpoint: 35.6 °F\nWind Direction: 270 °\nWind Speed: 7.56 km/h\nBarometric Pressure: 102170 Pa\nVisibility: 16090 m\nRelative Humidity: 65.848771416258 %")
  end

  scenario "User submits form without address" do
    visit root_path

    fill_in "Address:", with: ""
    click_button "Get Weather"

    expect(page).to have_content("Address cannot be blank.")
  end
end
