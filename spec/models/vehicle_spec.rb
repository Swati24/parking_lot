require_relative 'spec_dependencies.rb'

describe Vehicle do
	include HelperMethods
	before(:all) do
		Parking.unset_current_parking
		@registration_number = generate_car_number
		@colour = 'Black'
		@vehicle_create_options = {registration_number: @registration_number, colour: @colour }
  end

	describe "#create_for_parking" do
	  it "will create a new vehicle for parking" do
			Parking.execute_command('create_parking_lot 6')
			parking = Parking.current_parking
			first_available_slot = parking.first_available_slot

	  	expect(parking.vehicles.count).to eql(0)
	  	expect(first_available_slot.state).to eql(0)
	  	
	  	Vehicle.create_for_parking(parking, first_available_slot, @vehicle_create_options)
	  	vehicle = Vehicle.with_registration_number(@registration_number)
	  	
	  	first_available_slot.reload

	  	expect(vehicle).not_to be_nil
	  	expect(parking.vehicles).to include(vehicle)
			expect(vehicle.slot).to eql(first_available_slot)
			expect(first_available_slot.state).to eql(1)
	  end

	  it "will map existing vehicle to new parking and new slot" do
			Parking.execute_command('create_parking_lot 10')
			parking = Parking.current_parking

			vehicle = Vehicle.with_registration_number(@registration_number)
			before_parking_id = vehicle.parking_id
			before_slot_id = vehicle.slot_id
			before_vehicles_count = Vehicle.count

			first_available_slot = parking.first_available_slot

	  	Vehicle.create_for_parking(parking, parking.first_available_slot, @vehicle_create_options)
	  	vehicle.reload

	  	after_vehicles_count = Vehicle.count

	  	expect(after_vehicles_count).to eql(before_vehicles_count)
	  	expect(before_slot_id).not_to eql(vehicle.slot_id)
			expect(before_parking_id).not_to eql(vehicle.parking_id)
	  end
	end

	describe '#slot_number' do
		it 'will return the slot number for the parked vehicle' do
			parking = Parking.current_parking
			first_available_slot = parking.first_available_slot
			first_available_slot_number = first_available_slot.number

			registration_number = generate_car_number
	  	Parking.execute_command(park_command({car_number: registration_number}))
	  	vehicle = Vehicle.with_registration_number(registration_number)

	  	expect(vehicle.slot_number).to eql(first_available_slot_number)
		end
	end

	describe '#get_parking_information_in_string' do
		it 'will return the parking information of the vehicle' do
			parking = Parking.current_parking
			first_available_slot = parking.first_available_slot
			first_available_slot_number = first_available_slot.number
			registration_number = generate_car_number
			colour = get_colour_randomly

			string = "#{first_available_slot_number} #{registration_number} #{colour}"

	  	Parking.execute_command(park_command({car_number: registration_number, colour: colour}))
	  	vehicle = Vehicle.with_registration_number(registration_number)

	  	expect(vehicle.get_parking_information_in_string).to eql(string)
		end
	end

end