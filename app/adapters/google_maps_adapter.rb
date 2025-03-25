require "google_maps_service"

# Example response from Google Geocode API:
# https://developers.google.com/maps/documentation/geocoding/requests-geocoding
# {
#     "results": [
#         {
#             "address_components": [
#                 {
#                     "long_name": "1600",
#                     "short_name": "1600",
#                     "types": [
#                         "street_number"
#                     ]
#                 },
#                 {
#                     "long_name": "Amphitheatre Parkway",
#                     "short_name": "Amphitheatre Pkwy",
#                     "types": [
#                         "route"
#                     ]
#                 },
#                 {
#                     "long_name": "Mountain View",
#                     "short_name": "Mountain View",
#                     "types": [
#                         "locality",
#                         "political"
#                     ]
#                 },
#                 {
#                     "long_name": "Santa Clara County",
#                     "short_name": "Santa Clara County",
#                     "types": [
#                         "administrative_area_level_2",
#                         "political"
#                     ]
#                 },
#                 {
#                     "long_name": "California",
#                     "short_name": "CA",
#                     "types": [
#                         "administrative_area_level_1",
#                         "political"
#                     ]
#                 },
#                 {
#                     "long_name": "United States",
#                     "short_name": "US",
#                     "types": [
#                         "country",
#                         "political"
#                     ]
#                 },
#                 {
#                     "long_name": "94043",
#                     "short_name": "94043",
#                     "types": [
#                         "postal_code"
#                     ]
#                 },
#                 {
#                     "long_name": "1351",
#                     "short_name": "1351",
#                     "types": [
#                         "postal_code_suffix"
#                     ]
#                 }
#             ],
#             "formatted_address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
#             "geometry": {
#                 "location": {
#                     "lat": 37.4222804,
#                     "lng": -122.0843428
#                 },
#                 "location_type": "ROOFTOP",
#                 "viewport": {
#                     "northeast": {
#                         "lat": 37.4237349802915,
#                         "lng": -122.083183169709
#                     },
#                     "southwest": {
#                         "lat": 37.4210370197085,
#                         "lng": -122.085881130292
#                     }
#                 }
#             },
#             "place_id": "ChIJRxcAvRO7j4AR6hm6tys8yA8",
#             "plus_code": {
#                 "compound_code": "CWC8+W7 Mountain View, CA",
#                 "global_code": "849VCWC8+W7"
#             },
#             "types": [
#                 "street_address"
#             ]
#         }
#     ],
#     "status": "OK"
# }

class GoogleMapsAdapter
  def initialize
    @client = GoogleMapsService::Client.new(key: ENV["GOOGLE_MAPS_API_KEY"])
    Rails.logger.info "GoogleMapsAdapter initialized with key: #{ENV["GOOGLE_MAPS_API_KEY"]}"
  end

  def geolocate(address_text)
    results = @client.geocode(address_text)
    if results.any?
      address = Address.new(plain_text: address_text)

      location = results.first[:geometry][:location]
      address.latitude = location[:lat].round(4)
      address.longitude = location[:lng].round(4)
      address.formatted_address = results.first[:formatted_address]
      address.street_number = extract_address_component(results.first, "street_number")
      address.street_name = extract_address_component(results.first, "route")
      address.city = extract_address_component(results.first, "locality")
      address.state = extract_address_component(results.first, "administrative_area_level_1")
      address.postal_code = extract_address_component(results.first, "postal_code")
      address.country = extract_address_component(results.first, "country")
    else
      return nil
    end

    address
  end

  private

  def extract_address_component(result, type)
    result[:address_components].each do |component|
      return component[:long_name] if component[:types].include?(type)
    end
    nil
  end
end
