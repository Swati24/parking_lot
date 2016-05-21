require_relative 'spec_dependencies.rb'

describe Slot do
	include HelperMethods
	before(:all) do
		Parking.execute_command('create_parking_lot 6')
		2.times { Parking.execute_command(park_command) }
  end

  before(:each) do
		@current_parking = Parking.current_parking
  end

	describe "#update_parking_available_slots_count" do
	  it "should decrement the parking available_slot_count when state of slot is changed to 1" do
			first_available_slot = @current_parking.first_available_slot
			before_available_slots_count = @current_parking.available_slots_count

			first_available_slot.state = 1
			first_available_slot.save

			@current_parking.reload

	  	expect(before_available_slots_count - @current_parking.available_slots_count).to eql(1)
	  end
	end

	describe '#leave_unoccupied' do
		it 'will change the state of slot to -1' do
			slot = @current_parking.slots.busy.first
			vehicle = slot.vehicle
			slot.leave_unoccupied
			
			slot.reload
			vehicle.reload

	  	expect(slot.state).to eql(-1)
	  	expect(vehicle.slot_id).to be_nil
		end
	end

end