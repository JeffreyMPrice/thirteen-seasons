# Thirteen Seasons


I dedicate this app to my home state of NC, in which there are said to be thirteen seasons.
* Winter
* Fool’s Spring
* Second Winter
* Spring of Deception
* Third Winter
* The Pollening
* Mud Season
* Actual Spring
* Summer
* Satan’s Front Port
* Falso Fall
* Second Summer
* Actual Fall


## Project Requirements
* Rails 8
* Ruby 3.3.5


I am aware that this position will be working on a Rails 5/6 application. I recommend the team upgrade to at least Rails 7.1.x as any version older than that will be beyond it's end of life
and will no longer be recieving security updates. Please see the [Ruby on Rails Maintenance Policy](https://rubyonrails.org/maintenance) for more information.


## Third Party Gems
Since time is of the essence, I will use third party gems to speed development. All gems being used are being actively maintained. This does not include gems used for testing.
* [google-maps-services-ruby](https://github.com/langsharpe/google-maps-services-ruby) - Used for geolocating the address to recieve latitude and longitude. You are required to use a Google
API Key to access the system. I will provide in a seperate channel the API key to use for this project, or you may provide your own.
* [weather_gov_api](https://github.com/JeffreyMPrice/weather_gov_api) - This is used to get the current conditions and forecast data from the [weather.gov api](https://www.weather.gov/documentation/services-web-api). No API key is required.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd thirteen-seasons
    ```
2.  **Install dependencies:**
    ```bash
    bundle install
    ```
3.  **Set up environment variables:**
    *   Create a `.env` file in the project root.
    *   Copy the contents of `.env.sample` into `.env`.
    *   Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual Google Maps API key.
        - `ADMIN_EMAIL`: The email address used for API requests. Weather.gov requests this be a part of the user agent.
        - `WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES`: (Optional) The cache timeout for weather data in minutes. Defaults to 30 if not set.
4.  **Run the tests:**
    ```bash
    bundle exec rspec
    ```
5.  **Start the server:**
    ```bash
    rails server
    ```

## Discussion of Best Practices, Design Decisions, Patterns, and a bunch of other stuff

### Patterns Used
* The main pattern used is Service Objects with Adapaters. This can be seen in both the GeolocationService and WeatherService classes. The reason I also add an adapter is to make it easy to switch out third party providers for either geolocation or weather if we desired to in the future. Adding a new adapter and using it is all that would need to be done.
* I also opted not to persist data to a database since it did not seem necessary. I did make use of ActiveModel in my classes for validation on the Location class as well as for easy initializers. I overrode the == for easy of testing purposes.

Improvements I would make for production:
* With the addition of adapters, we could easily add in a circuit breaker to the service objects that if a third party tool was down, we'd be able to easily switch to a backup provider for geolocation or weather.
* I would also want to add a rate limiter (as appropriate) on the services to ensure I didn't have any issues with my quotas or end up getting throttled.
* Likewise I would want to implement some rate limiting on my own service to ensure everyone plays nice.

### Object Decomposition
#### Models
- Location - Holds the geolocation information.
    - address
    - latitude 
    - longitude
    - street_number
    - street_name
    - city
    - state
    - postal_code
    - country
    - formatted_address
* Weather - Holds the current weather
    - temperature
    - wind
    - dewpoint
    - wind_direction
    - wind_speed
    - barometric_pressure
    - visibility
    - relative_humidity
* Forecast - Holds the forecast weather (not the same information as weather!)
    - name
    - start_time
    - end_time
    - is_daytime
    - temperature
    - temperature_unit
    - short_forecast
    - detailed_forecast

#### Services
* GeolocationService - The service expects a text address and an adapter that answers to a message of :geolocate returning a hydrated Location object
* WeatherService - The service expects to be given a Location with values for Latitude, Longitude and Postcode filled out as well as an adapter that responds to :current_weather and :forecast.

#### Adapters
* GoogleMapsAdapter - Geolocates a text address and returns a location using the Google Maps Geolocation Service
* WeatherGovAdapter - Returns the current weather and forecast for locations in the US using the Weather.gov API

### Continuous Integration

GitHub Actions are configured to run tests and quality checks on every push and pull request
* Brakeman vulnerability scanner (https://brakemanscanner.org/)
* importmap audit scans javascript libraries for known security issues (https://github.com/rails/importmap-rails)
* Rubocop linting for consistent code formate and best practices (https://rubocop.org/)
* Run all RSpec tests (https://rspec.info/)


### Testing

This project uses RSpec for testing. Code coverage is measured using SimpleCov, with a minimum requirement of 90% overall coverage and 80% per file.

Other notes:
* I use timecop (https://github.com/travisjeffery/timecop) to test caching and ensure the cache strategy is working.
* Extensive use of test doubles to isolate tests to just the class being tested and avoid calls out to the real service.
* I did setup WebMock to alert me when any call makes out past my doubles, even though I'm not using it for mocking.

Improvements I would make on my current testing:
* Use factory_bot (https://github.com/thoughtbot/factory_bot) for setting up test data. There is a lot of duplication in my tests at the moment. Using a tool like factory_bot would make tests much more efficient.


### Scalability
* In terms of scalability, there aren't really any serious issues at play here other than rate limits on my API use. If I were in the cloud I could easily scale up my instance size or implement multi-instances. To scale larger I would also want to switch from an in-memory cache for Rails and move to Redis or another caching server.

### General Notes and areas of improvement
* The UI is quite horrible. It's been a bit since I've done front-end work, so instead of spending a lot of time doing a poor job, I did a really poor job quickly and focused on the backend.
* Secret management would go through an encrypted secret store instead of in a plaintext .env file!

## Closing Thoughts
* I truly enjoyed building this project. It’s more than just fetching weather data! Thank you for the opportunity to be considered for this role. I welcome any feedback or questions you may have.

