class WeatherService
  def initialize(adapter: WeatherGovAdapter.new)
    @adapter = adapter
  end

  def current_weather(location)
    from_cache = true
    weather = Rails.cache.fetch(cache_key(location.postal_code, "current_weather"), expires_in: current_weather_cache_timeout) do
      from_cache = false
      Rails.logger.info "Cache miss for current_weather: #{cache_key(location.postal_code, "current_weather")}"
      @adapter.current_weather(location.latitude, location.longitude)
    end
    { weather: weather, from_cache: from_cache }
  end

  def forecast(location)
    from_cache = true
    forecast = Rails.cache.fetch(cache_key(location.postal_code, "forecast"), expires_in: current_weather_cache_timeout) do
      from_cache = false
      Rails.logger.info "Cache miss for forecast: #{cache_key(location.postal_code, "forecast")}"
      @adapter.forecast(location.latitude, location.longitude)
    end
    { forecast: forecast, from_cache: from_cache }
  end

  private

  def cache_key(zipcode, type)
    "#{Rails.env}/weather_service/#{type}/#{zipcode}"
  end

  def current_weather_cache_timeout
    timeout_minutes = ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"]&.to_i
    if timeout_minutes.nil? || timeout_minutes <= 0
      Rails.logger.warn "WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES not set or invalid. Defaulting to 30 minutes."
      30.minutes
    else
      timeout_minutes.minutes
    end
  end
end
