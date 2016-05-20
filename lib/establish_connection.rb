require 'yaml'

db_config = YAML.load_file('lib/config/database.yml')
ActiveRecord::Base.establish_connection(db_config)