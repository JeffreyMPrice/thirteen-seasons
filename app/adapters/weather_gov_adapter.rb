require "weather_gov_api"

class WeatherGovAdapter
  def initialize
    @client = WeatherGovApi::Client.new(user_agent: "Thirteen Seasons, #{ENV["ADMIN_EMAIL"]}")
  end

  # https://www.weather.gov/documentation/services-web-api#/default/station_observation_latest
  # {
  #   "@context": [
  #     "https://geojson.org/geojson-ld/geojson-context.jsonld",
  #     {
  #       "@version": "1.1",
  #       "wx": "https://api.weather.gov/ontology#",
  #       "s": "https://schema.org/",
  #       "geo": "http://www.opengis.net/ont/geosparql#",
  #       "unit": "http://codes.wmo.int/common/unit/",
  #       "@vocab": "https://api.weather.gov/ontology#",
  #       "geometry": {
  #         "@id": "s:GeoCoordinates",
  #         "@type": "geo:wktLiteral"
  #       },
  #       "city": "s:addressLocality",
  #       "state": "s:addressRegion",
  #       "distance": {
  #         "@id": "s:Distance",
  #         "@type": "s:QuantitativeValue"
  #       },
  #       "bearing": {
  #         "@type": "s:QuantitativeValue"
  #       },
  #       "value": {
  #         "@id": "s:value"
  #       },
  #       "unitCode": {
  #         "@id": "s:unitCode",
  #         "@type": "@id"
  #       },
  #       "forecastOffice": {
  #         "@type": "@id"
  #       },
  #       "forecastGridData": {
  #         "@type": "@id"
  #       },
  #       "publicZone": {
  #         "@type": "@id"
  #       },
  #       "county": {
  #         "@type": "@id"
  #       }
  #     }
  #   ],
  #   "id": "https://api.weather.gov/stations/KMYZ/observations/2025-03-25T14:55:00+00:00",
  #   "type": "Feature",
  #   "geometry": {
  #     "type": "Point",
  #     "coordinates": [
  #       -96.63,
  #       39.25
  #     ]
  #   },
  #   "properties": {
  #     "@id": "https://api.weather.gov/stations/KMYZ/observations/2025-03-25T14:55:00+00:00",
  #     "@type": "wx:ObservationStation",
  #     "elevation": {
  #       "unitCode": "wmoUnit:m",
  #       "value": 319
  #     },
  #     "station": "https://api.weather.gov/stations/KMYZ",
  #     "stationId": "KMYZ",
  #     "stationName": "Marysville Municipal Airport",
  #     "timestamp": "2025-03-25T14:55:00+00:00",
  #     "rawMessage": "KMYZ 251455Z AUTO 27004KT 10SM CLR 08/02 A3017 RMK AO2",
  #     "textDescription": "Clear",
  #     "icon": "https://api.weather.gov/icons/land/day/skc?size=medium",
  #     "presentWeather": [],
  #     "temperature": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": 8,
  #       "qualityControl": "V"
  #     },
  #     "dewpoint": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": 2,
  #       "qualityControl": "V"
  #     },
  #     "windDirection": {
  #       "unitCode": "wmoUnit:degree_(angle)",
  #       "value": 270,
  #       "qualityControl": "V"
  #     },
  #     "windSpeed": {
  #       "unitCode": "wmoUnit:km_h-1",
  #       "value": 7.56,
  #       "qualityControl": "V"
  #     },
  #     "windGust": {
  #       "unitCode": "wmoUnit:km_h-1",
  #       "value": null,
  #       "qualityControl": "Z"
  #     },
  #     "barometricPressure": {
  #       "unitCode": "wmoUnit:Pa",
  #       "value": 102170,
  #       "qualityControl": "V"
  #     },
  #     "seaLevelPressure": {
  #       "unitCode": "wmoUnit:Pa",
  #       "value": null,
  #       "qualityControl": "Z"
  #     },
  #     "visibility": {
  #       "unitCode": "wmoUnit:m",
  #       "value": 16090,
  #       "qualityControl": "C"
  #     },
  #     "maxTemperatureLast24Hours": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": null
  #     },
  #     "minTemperatureLast24Hours": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": null
  #     },
  #     "precipitationLastHour": {
  #       "unitCode": "wmoUnit:mm",
  #       "value": null,
  #       "qualityControl": "Z"
  #     },
  #     "precipitationLast3Hours": {
  #       "unitCode": "wmoUnit:mm",
  #       "value": null,
  #       "qualityControl": "Z"
  #     },
  #     "precipitationLast6Hours": {
  #       "unitCode": "wmoUnit:mm",
  #       "value": null,
  #       "qualityControl": "Z"
  #     },
  #     "relativeHumidity": {
  #       "unitCode": "wmoUnit:percent",
  #       "value": 65.848771416258,
  #       "qualityControl": "V"
  #     },
  #     "windChill": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": 6.774493176828889,
  #       "qualityControl": "V"
  #     },
  #     "heatIndex": {
  #       "unitCode": "wmoUnit:degC",
  #       "value": null,
  #       "qualityControl": "V"
  #     },
  #     "cloudLayers": [
  #       {
  #         "base": {
  #           "unitCode": "wmoUnit:m",
  #           "value": null
  #         },
  #         "amount": "CLR"
  #       }
  #     ]
  #   }
  # }
  def current_weather(latitude, longitude)
    response = @client.current_weather(latitude: latitude, longitude: longitude)
    if response.success?
      @properties = response.data["properties"]
      Weather.new(
        # comes back as C, need to convert to F
        temperature: celsius_to_fahrenheit(extract_weather_component("temperature")),
        dewpoint: celsius_to_fahrenheit(extract_weather_component("dewpoint")),
        wind_direction: extract_weather_component("windDirection"),
        wind_speed: extract_weather_component("windSpeed"),
        barometric_pressure: extract_weather_component("barometricPressure"),
        visibility: extract_weather_component("visibility"),
        relative_humidity: extract_weather_component("relativeHumidity"),
      )
    else
      Rails.logger.error "Weather API request failed: #{response.body}"
      nil
    end
  end

  private

  def extract_weather_component(type)
    @properties[type]["value"]
  end

  def celsius_to_fahrenheit(celsius)
    return nil if celsius.nil?
    (celsius * 9.0 / 5.0) + 32
  end
end
