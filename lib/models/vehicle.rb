class Vehicle < ActiveRecord::Base

  belongs_to :parking
  belongs_to :slot

  scope :parked, -> { where('slot_id is NOT NULL')}
  scope :with_colour, -> (colour) { where(colour: colour) }
  scope :with_registration_number, -> (registration_number) { where(registration_number: registration_number).first }

  validates_uniqueness_of :registration_number

  # - This method finds or creates a vehicle for the parking.
  #
  # == Parameters:
  # Mandatory::
  #  parking object
  # options => { registration_number: 'KA-01-HH-9999' , colour: White, slot_id: <slot object> } 
  #
  #  == Returns:
  #  Allocated slot number: 1
  #
  def self.create_for_parking(parking, slot, options)
    vehicle = where(registration_number: options[:registration_number]).first
    if vehicle.nil?
      vehicle = new(options)
    end
  
    vehicle.slot_id = slot.id
    vehicle.parking_id = parking.id
    if vehicle.save
      vehicle.book_slot
    end
    "Allocated slot number: #{vehicle.slot_number}"

  end

  # - This method books the slot for the vehicle. i.e. sets the state of the vehicle.
  #
  #  == Returns:
  #  true/false
  #
  def book_slot
    slot.state = 1
    slot.save!
  end

  # - This method returns the slot number corresponding to the slot
  #
  #  == Returns:
  #  1
  #
  def slot_number
    if slot.present?
      slot.number
    else
      nil
    end
  end

  # - This method returns the vehicle's parking information in a string
  #
  #  == Returns:
  #  "1 KA-01-HH-9999 White"
  #
  def get_parking_information_in_string
    "#{slot_number} #{registration_number} #{colour}"
  end
end
