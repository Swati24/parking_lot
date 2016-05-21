require_relative 'spec_dependencies.rb'

describe Parking do
	include HelperMethods
	before(:all) do
		Parking.unset_current_parking
  end

  before(:each) do
  	@current_parking = Parking.current_parking
  end

	describe "#create_parking_lot" do
	  it "will create a new parking" do
	  	slots_before_count = Slot.count
	  	expect(Parking.current_parking).to be_nil
			
			Parking.execute_command('create_parking_lot 6')
			parking = Parking.current_parking
			slots_after_count = Slot.count

			expect(parking).to be_an_instance_of Parking
			expect(parking.available_slots_count).to eql 6
			expect(parking.slots.count).to eql 6
			expect(slots_after_count - slots_before_count).to eql 6
	  end
	end

	describe "#park" do
	  it "finds or create a new vehicle and assign a slot to the vehicle in the current parking" do			
			Parking.execute_command(park_command)
			@current_parking.reload	
			expect(@current_parking.vehicles.count).to eql(1)
			expect(@current_parking.slots.count - @current_parking.available_slots.count).to eql(1)
			expect(@current_parking.slots_count - @current_parking.available_slots_count).to eql(1)
	  end

	  it "will use all slots for parking" do
	  	available_slots = @current_parking.available_slots_count

	  	available_slots.times do 
	  		Parking.execute_command(park_command)
	  	end
	  	@current_parking.reload	
	  	expect(@current_parking.vehicles.count).to eql(@current_parking.slots_count)
			expect(@current_parking.available_slots.count).to eql(0)
			expect(@current_parking.available_slots_count).to eql(0)
		end

		it "will return a sorry message since no parkings are available." do
	  	message = Parking.execute_command(park_command)
	  	@current_parking.reload	
	  	expect(message).to include("Sorry")
		end
	end

	describe '#leave' do
		it 'will leave a slot vacated change state of slot to -1' do
			slot = @current_parking.slots.order('rand()').first
			vehicle = slot.vehicle
			expect(slot.state).to eql(1)
			Parking.leave([slot.number])
			slot.reload
			vehicle.reload
			expect(slot.state).to eql(-1)
			expect(vehicle.slot_id).to be_nil
		end
	end

	describe '#registration_numbers_for_cars_with_colour' do
		it 'will return 2 registration numbers for cars with colour White.' do
			parking = Parking.create_parking_lot(['6'])
			colour = 'White'
			count = 2
			count.times do 
				Parking.execute_command(park_command({colour: colour}))
			end

			registration_number_array = 
				Parking.registration_numbers_for_cars_with_colour([colour]).split(',')

			expect(registration_number_array.length).to eql(count)
		end
	end

	describe '#slot_numbers_for_cars_with_colour' do
		it 'will return 2 slot numbers for cars with colour White.' do
			colour = 'White'
			count = 2

			slot_number_array = 
				Parking.registration_numbers_for_cars_with_colour([colour]).split(',')

			expect(slot_number_array.length).to eql(count)
		end
	end


	describe '#slot_number_for_registration_number' do
		it 'will return the slot number for car with registration number' do
			registration_number = 'KA-01-BB-0001'
			first_available_slot = @current_parking.first_available_slot
			Parking.execute_command(park_command({car_number: registration_number}))

			vehicle = @current_parking.vehicles.where(registration_number: registration_number).first

			expect(vehicle.slot).to eql(first_available_slot)
		end
	end

	describe '#unset_current_parking' do
		it 'will unset the variable @current_parking to nil' do
			expect(@current_parking).not_to be_nil
			Parking.unset_current_parking
			expect(Parking.current_parking).to be_nil
		end
	end

end