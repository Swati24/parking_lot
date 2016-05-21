# ParkingLot Problem

### Set up

Run the below commands to set up the project.

* Copy the content and save the file with name .rvmrc in root directory -
```console
rvm use 2.2.3@parking_lot --create
```

* Install Gems -
```ruby
bundle install
```

* Create database.yml in config directory. database_example.yml has been added for reference. username and pasword for mysql server needs to be added.

* Create Database and add tables-
```ruby
rake db:create
```

* To run all tests-
```ruby
rspec
```

* To run parking_spec.rb tests-
```ruby
rspec spec/models/parking_spec.rb
```

* Valid Commands -
```ruby
['create_parking_lot', 'park', 'leave', 'status', 'registration_numbers_for_cars_with_colour', 'slot_numbers_for_cars_with_colour', 'slot_number_for_registration_number'] 
```

### About the project -
This program accepts certain input command and does verious actions like Creating a Parking Lot, Parking the vehicle, assigning the slot. The commands can be writen in a file and pased to the rake task as a argument or the commands can be run in interactive mode shell. If file_path is passed the output is written in an output file which is located in data folder else the output is printed in the shell itself.


## Solution - How to run the program ?
	
	Interactive Mode Command :  ruby lib/parking_lot.rb
	File Mode Command : ruby lib/parking_lot.rb "data/input.txt > data/output.txt"

