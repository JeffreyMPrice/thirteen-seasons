require 'rails_helper'

RSpec.feature "Weather Caching", type: :feature do
  let(:address) { "123 Main St" }
  let(:geolocated_address) do
    Location.new(
      address: address,
      latitude: 37.7749,
      longitude: -122.4194,
      formatted_address: "#{address}, San Francisco, CA 94103, USA"
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
      relative_humidity: 65.848771416258
    )
  end
  let(:forecast_data) do
    [
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
    ]
  end
  let(:geolocation_service) { instance_double(GeolocationService) }


  before(:each) do
    allow(GeolocationService).to receive(:new).and_return(geolocation_service)
    allow(geolocation_service).to receive(:geolocate).and_return(geolocated_address)
    allow_any_instance_of(WeatherGovAdapter).to receive(:current_weather).and_return(weather_data)
    allow_any_instance_of(WeatherGovAdapter).to receive(:forecast).and_return(forecast_data)
  end

  scenario "caches the weather data for a location" do
    # First request - should fetch from the adapter
    visit root_path
    fill_in "Address", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Temperature: 46.4")
    expect(page).to have_content("Dewpoint: 35.6")
    expect(page).to have_content("Wind Direction: 270")
    expect(page).to have_content("Current Weather (Fresh Data)")

    # Second request - should fetch from the cache
    visit root_path
    fill_in "Address", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Temperature: 46.4")
    expect(page).to have_content("Dewpoint: 35.6")
    expect(page).to have_content("Wind Direction: 270")
    expect(page).to have_content("Current Weather (From Cache)")
  end

  scenario "expires the cache after 30 minutes" do
    # First request - should fetch from the adapter
    visit root_path
    fill_in "Address", with: "123 Main St"
    click_button "Get Weather"

    expect(page).to have_content("Current Weather (Fresh Data)")

    # Advance time by 31 minutes
    Timecop.travel(31.minutes.from_now) do
      visit root_path
      fill_in "Address", with: "123 Main St"
      click_button "Get Weather"

      expect(page).to have_content("Current Weather (Fresh Data)")
    end
  end
end
