class Slot < ActiveRecord::Base

  belongs_to :parking

  has_one :vehicle

  scope :busy, -> { where(state: 1) }

  after_save :update_parking_available_slots_count

  # - This method is invoked when a slot is unassigned assigned to a vehicle. It increments or decrements the 
  # counter of update_parking_available_slots_count in parking object respectively. 
  #
  #  == Returns:
  #  true/false
  #
  def update_parking_available_slots_count
    if state_changed?
      if state != 0
        parking.decrement :available_slots_count
      else
        parking.increment :available_slots_count
      end
      parking.save
    end
  end

  # - This method checks if the slot is already being used by vehicle.
  #
  #  == Returns:
  #  true/false
  #
  def already_used?
    vehicle.present? and state == 1
  end

  # - This method sets the state of slot to -1
  #
  #  == Returns:
  #  true/false
  #
  def leave_unoccupied
    vehicle = self.vehicle
    if mark_free(-1)
      if vehicle.present?
        vehicle.update_attributes!(slot_id: nil)
      end
    end
  end

  # - This method sets the state of slot to the value passed in arguments.
  #
  # == Parameters:
  # Mandatory::
  #  state 
  #
  #  == Returns:
  #  true/false
  #
  def mark_free(state = 0)
    self.state = state
    self.save
  end
end
