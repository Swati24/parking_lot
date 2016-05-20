require 'yaml'
require 'active_record'

db_config = YAML.load_file('lib/config/database.yml')

namespace :db do
  desc "Create the database"
  task :create do
    ActiveRecord::Base.establish_connection(db_config.except('database'))
    ActiveRecord::Base.connection.create_database(db_config["database"])
    
    Rake::Task['db:migrate'].invoke

    puts "Database created and migrated."
  end

  desc "Drop the database"
  task :drop do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.drop_database(db_config["database"])
    puts "Database dropped."
  end


  desc 'Create Tables'
  task :migrate do 
    ActiveRecord::Base.establish_connection(db_config)
    
    ActiveRecord::Schema.define do
      
      create_table :parkings do |t|
        t.integer :slots_count
        t.integer :available_slots_count
        t.integer :active

        t.timestamps null: false
      end

      create_table :vehicles do |t|
        t.integer :parking_id
        t.string :registration_number
        t.string :colour
        t.integer :slot_id

        t.timestamps null: false
      end

      create_table :slots do |t|
        t.integer :number
        t.integer :parking_id
        t.integer :state, default: 0

        t.timestamps null: false
      end
    
    end
  end
end

