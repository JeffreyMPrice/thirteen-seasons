class Location
  include ActiveModel::Model
  attr_accessor :plain_text, :latitude, :longitude, :street_number, :street_name, :city, :state, :postal_code, :country, :formatted_address

  validates :plain_text, presence: true
end
