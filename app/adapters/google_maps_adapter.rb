require "google_maps_service"

# Example response from Google Geocode API:
# https://developers.google.com/maps/documentation/geocoding/requests-geocoding
class GoogleMapsAdapter
  def initialize
    @client = GoogleMapsService::Client.new(key: ENV["GOOGLE_MAPS_API_KEY"])
    Rails.logger.info "GoogleMapsAdapter initialized"
  end

  def geolocate(address)
    results = @client.geocode(address)
    if results.any?
      location = Location.new(address: address)

      geolocation = results.first[:geometry][:location]
      location.latitude = geolocation[:lat].round(4)
      location.longitude = geolocation[:lng].round(4)
      location.formatted_address = results.first[:formatted_address]
      location.street_number = extract_address_component(results.first, "street_number")
      location.street_name = extract_address_component(results.first, "route")
      location.city = extract_address_component(results.first, "locality")
      location.state = extract_address_component(results.first, "administrative_area_level_1")
      location.postal_code = extract_address_component(results.first, "postal_code")
      location.country = extract_address_component(results.first, "country")
    else
      return nil
    end

    location
  end

  private

  def extract_address_component(result, type)
    result[:address_components].each do |component|
      return component[:long_name] if component[:types].include?(type)
    end
    nil
  end
end
