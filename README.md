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
Since time is of the essence, I will use third party gems to speed development. All gems being used are being actively maintained.
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

## Testing

This project uses RSpec for testing. Code coverage is measured using SimpleCov, with a minimum requirement of 90% overall coverage and 80% per file.

## Code Quality

RuboCop is used to enforce code style and identify potential issues.

## Secure Coding

Brakeman is used to check for secure coding best practices

## Continuous Integration

GitHub Actions are configured to run tests and quality checks on every push and pull request.

## Health Check

The `/up` endpoint is available for health checks.

## More to come...
* ...
* ...
