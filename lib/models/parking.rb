class Parking < ActiveRecord::Base

  VALID_COMMANDS = ['create_parking_lot', 'park', 'leave', 'status', 'registration_numbers_for_cars_with_colour', 'slot_numbers_for_cars_with_colour', 'slot_number_for_registration_number'] 

  has_many :vehicles
  has_many :slots
  has_many :available_slots, -> { where(state: 0) }, class_name: 'Slot'

  after_save :set_current_parking

  def self.read_file_lines(file_path)
    File.readlines(file_path).map{ |l| l.chomp }.reject{ |l| l == '' }
  end

  # - This method reads the file from the file path and processes action to execute the commands.
  #
  # == Parameters:
  # Optional::
  #   file_path
  #
  #  == Returns:
  #  true
  #
  def self.read_file(input_file_path, output_file_path)
    input_commands = read_file_lines(input_file_path)
    output_messages = []
  
    input_commands.each_with_index do |input_command, index|
      output_messages << execute_command(input_command)
    end

    write_in_file(output_file_path, output_messages) 
    unset_current_parking

    return true
  end

  # - This method processed the input command. It splits the actual command and arguments. 
  # CHecks if the command is valid and invokes the corresponding action to the command.
  #
  # == Parameters:
  # Mandatory::
  #   input_command - create_parking_lot 6
  #
  #  == Returns:
  #  Message returned by the invoked action.
  #
  def self.execute_command(input_command)
    command, *arguments = input_command.split
    output_message =
      if VALID_COMMANDS.include?(command)
        send(command, arguments)
      else
        'command not valid'
      end

    output_message
  end


  # - This method writes the output in the file.
  #
  # == Parameters:
  # Mandatory::
  #  Array of messages
  #
  def self.write_in_file(output_file_path, output_messages)
    file_out = File.open(output_file_path, "w")
    file_out << output_messages.join("\n\n")
    file_out.close
  end

  # - This method creates a new parking lot with the given number of slots. 
  # It also sets the global variable current_parking to the parking created.
  #
  # == Parameters:
  # Mandatory::
  # array of slots - ['6']
  #
  #  == Returns:
  #  Created a parking lot with 6 slots
  #
  def self.create_parking_lot(options)
    slots_count = options.first.to_i
    parking = new(slots_count: slots_count, available_slots_count: slots_count)
    slots = slots_count.times {|index| parking.slots.build(number: index + 1) }
    parking.save!
    parking.set_current_parking

    "Created a parking lot with #{slots_count} slots"
  end


  # - This method finds or creates a new vehicle with the registration number and aissn the slot to the
  # vehicle and map the parking_id to the current parking.
  #
  # == Parameters:
  # Mandatory::
  # array of registration_number and colour - ['KA-01-HH-9999', 'White']
  #
  #  == Returns:
  #  Allocated slot number: 1
  #
  def self.park(parameters)
    options = { registration_number: parameters[0], colour: parameters[1] }
    first_available_slot = current_parking.first_available_slot
    message = 
      if first_available_slot.present?
      Vehicle.create_for_parking(current_parking, first_available_slot, options)
      else
        'Sorry, parking lot is full'
      end
  end


  # - This method finds the slot with the passed slot number and vacates that slot. It sets the state of the slot to -1 
  # which correspons to the slot as unoccupied. If any vehicle is parked on this slot the slot is unlinked with the vehicle. 
  #
  # == Parameters:
  # Mandatory::
  # array of slot_number - [1]
  #
  #  == Returns:
  #  Slot number 1 is free
  #
  def self.leave(options)
    slot_number = options.first
    slot = current_parking.find_slot_by_number(slot_number)
    vehicle = slot.vehicle
    if slot.present?
      slot.leave_unoccupied
      "Slot number #{slot.number} is free"
    else
      'No such slot is available'
    end
  end


  # - This method returns the status of all the vehicles parked in the parking. 
  #
  # == Parameters:
  # None
  #
  #  == Returns:
  #  Slot No. Registration No.  Colour  1 KA-01-HH-1234 White 2 KA-01-HH-9999 White 3 KA-01-BB-0001 Black 
  #   4 KA-01-HH-7777 Red 5 KA-01-HH-2701 Blue  6 KA-01-HH-3141 Black
  #
  def self.status(options = [])
    current_parking.get_parking_status
  end

  # - This method dynamically generates methods for attributes registration_number and slot_number 
  # and returns the attribute values for the vehicles with colour passed as input.
  # == Example
  # def self.registration_numbers_for_cars_with_colour
  # end
  # == Parameters:
  # Mandatory::
  # array of colour - ['White']
  #
  #  == Returns:
  #  KA-01-HH-1234, KA-01-HH-9999, KA-01-P-333, DL-12-AA-9999
  #
  [:registration_number, :slot_number].each do |attribute|
    define_singleton_method("#{attribute}s_for_cars_with_colour") do |options|
      colour = options.first
      message = current_parking.get_attribute_values_for_cars_with_colour(colour, attribute)
    end
  end

  # - This method returns the slot_number for vehicle with registratin number passed as input
  #
  # == Parameters:
  # Mandatory::
  # array of registration_number - [KA-01-HH-1234]
  #
  #  == Returns:
  #  1 (Slot Number)
  #
  def self.slot_number_for_registration_number options
    registration_number = options.first
    current_parking.get_slot_number_for_registration_number registration_number
  end

  # - This method finds the required attribute value for cars with colour passed as input.
  #
  # == Parameters:
  # Mandatory::
  # colour - 'White'
  # attribute - slot_number
  #
  #  == Returns:
  #  Value of passed attribute.
  #
  def get_attribute_values_for_cars_with_colour colour, attribute
    message = vehicles.parked.with_colour(colour).collect(&attribute).join(', ')

    if message.blank?
      message = "No vehicles found with colour #{colour}"
    end

    message
  end

  # - This instance method returns the slot_number for vehicle with registration number passed as input
  #
  # == Parameters:
  # Mandatory::
  # registration_number - KA-01-HH-1234
  #
  #  == Returns:
  #  1 (Slot Number)
  #
  def get_slot_number_for_registration_number(registration_number)
    vehicle = vehicles.where(registration_number: registration_number).first
    message = 
      if vehicle.present?
        vehicle.slot_number
      else
        "No vehicle found with registration number number #{registration_number}"
      end
  end

  # - This method return slot object with number.
  #
  # == Parameters:
  # Mandatory::
  # slot_number - 1
  #
  #  == Returns:
  #  Slot object
  #
  def find_slot_by_number(slot_number)
    slots.where(number: slot_number).first
  end

  # - This method returns the first available slot.
  #
  #  == Returns:
  #  Free LSot object
  #
  def first_available_slot
    available_slots.first
  end

  # - This instance method returns the status of all the vehicles parked in the parking. 
  #
  # == Parameters:
  # None
  #
  #  == Returns:
  #  Slot No. Registration No.  Colour  1 KA-01-HH-1234 White 2 KA-01-HH-9999 White 3 KA-01-BB-0001 Black 
  #   4 KA-01-HH-7777 Red 5 KA-01-HH-2701 Blue  6 KA-01-HH-3141 Black
  #
  def get_parking_status
    message = "Slot No.\tRegistration No.\tColour"
    vehicles.parked.each do |vehicle|
      message = [message, vehicle.get_parking_information_in_string].join("\t")
    end

    message
  end

  # - This method sets the global variable for all the other actions. 
  #
  #  == Returns:
  #  Parking object
  #
  def set_current_parking
    @@current_parking = self
  end

  # - This method returns the current parking object. If current parking is not set it returns the last parking object in db.
  #
  #  == Returns:
  #  Parkig Object.
  #
  def self.current_parking
    if defined?(@@current_parking)
      (@@current_parking)
    else
      Parking.last.set_current_parking
    end    
  end

  # - This method unsets the current parking global variable.
  #
  def self.unset_current_parking
    @@current_parking = nil
  end

end
