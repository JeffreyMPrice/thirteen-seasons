class Location
  include ActiveModel::Model
  attr_accessor :address, :latitude, :longitude, :street_number, :street_name, :city, :state, :postal_code, :country, :formatted_address

  validates :address, presence: { message: "cannot be blank." }
  validate :must_be_us_address, if: -> { address.present? }

  private

  def must_be_us_address
    if country.nil?
      errors.add(:address, "could not be located.")
    elsif country != "United States"
      errors.add(:address, "must be located in the United States.")
    end
  end
end
