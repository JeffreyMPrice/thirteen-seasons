class GeolocationService
  def initialize(adapter: GoogleMapsAdapter.new)
    @adapter = adapter
  end

  def geolocate(address)
    @adapter.geolocate(address)
  end
end
