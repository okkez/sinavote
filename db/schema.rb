require 'rubygems'
require 'sequel'

DB = Sequel.sqlite('db/development.db')

DB.create_table :targets do
  primary_key :id
  string :uri, :unique => true, :null => false, :default => ''
  time :created_at
  time :updated_at

  index :uri
end

DB.create_table :comments do
  primary_key :id
  integer :target_id, :null => false
  integer :rating, :null => false, :default => 0
  text :message, :null => true
  time :created_at
  time :updated_at

  index :target_id
end
