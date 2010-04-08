require 'rubygems'
require 'sequel'

class AppSchema
  db_config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config/database.yml')))
  DB = Sequel.connect(db_config[ENV['RACK_ENV'].to_sym || :development])

  class << self
    def setup
      DB.create_table? :targets do
        primary_key :id
        String :uri, :unique => true, :null => false, :default => 'unknown'
        time :created_at
        time :updated_at

        index :uri
      end

      DB.create_table? :comments do
        primary_key :id
        integer :target_id, :null => false
        String :name, :null => false, :default => 'anonymous'
        String :email, :null => true
        integer :rating, :null => false, :default => 0
        text :message, :null => true
        time :created_at
        time :updated_at

        index :target_id
      end
    end
  end
end
