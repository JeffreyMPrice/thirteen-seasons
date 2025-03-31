require 'rails_helper'

RSpec.feature "WeatherForm", type: :feature do
  let(:address) { "123 Main St" }
  let(:geolocated_address) do
    Location.new(
      plain_text: address,
      latitude: 37.7749,
      longitude: -122.4194,
      formatted_address: "#{address}, San Francisco, CA 94103, USA"
    )
  end
  let(:weather_data) do
    { weather: Weather.new(
      temperature: 46.4,
      dewpoint: 35.6,
      wind_direction: 270,
      wind_speed: 7.56,
      barometric_pressure: 102170,
      visibility: 16090,
      relative_humidity: 65.848771416258,
    ),
      from_cache: false }
  end
  let(:forecast_data) do
    { forecast: [
      Forecast.new(
        name: "Tonight",
        start_time: "2023-10-27T18:00:00-07:00",
        end_time: "2023-10-28T06:00:00-07:00",
        is_daytime: false,
        temperature: 50,
        temperature_unit: "F",
        short_forecast: "Mostly Clear",
        detailed_forecast: "Mostly clear, with a low around 50."
      ),
      Forecast.new(
        name: "Saturday",
        start_time: "2023-10-28T06:00:00-07:00",
        end_time: "2023-10-28T18:00:00-07:00",
        is_daytime: true,
        temperature: 65,
        temperature_unit: "F",
        short_forecast: "Sunny",
        detailed_forecast: "Sunny, with a high near 65."
      )
    ],
    from_cache: false }
  end
  let(:weather_service) { instance_double(WeatherService) }
  let(:geolocation_service) { instance_double(GeolocationService) }

  before(:each) do
    allow(WeatherService).to receive(:new).and_return(weather_service)
    allow(GeolocationService).to receive(:new).and_return(geolocation_service)
    allow(geolocation_service).to receive(:geolocate).and_return(geolocated_address)
    allow(weather_service).to receive(:current_weather).with(geolocated_address).and_return(weather_data)
    allow(weather_service).to receive(:forecast).with(geolocated_address).and_return(forecast_data)
  end

  scenario "User submits address to get weather" do
    visit root_path

    fill_in "Address:", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Current Weather (Fresh Data)\nTemperature: 46.4 °F\nDewpoint: 35.6 °F\nWind Direction: 270 °\nWind Speed: 7.56 km/h\nBarometric Pressure: 102170 Pa\nVisibility: 16090 m\nRelative Humidity: 65.848771416258 %")
    expect(page).to have_content("7-Day Forecast")
    expect(page).to have_content("Tonight: Mostly Clear (Temperature: 50 F)")
    expect(page).to have_content("Saturday: Sunny (Temperature: 65 F)")
end

  scenario "User submits form without address" do
    visit root_path

    fill_in "Address:", with: ""
    click_button "Get Weather"

    expect(page).to have_content("Address cannot be blank.")
    expect(page).to_not have_content("7-Day Forecast")
  end
end
