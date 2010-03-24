# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'

require 'sequel'
DB = Sequel.sqlite('db/development.db')
require 'models/target.rb'
require 'models/comment.rb'

require 'json'

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  @targets = Target.order_by(:updated_at).all
  haml :index
end

#
# クエリパラメータの request に以下のような JSON データをセットする
#
#   {
#      "target" => { "url" => "http://example.com/path/to/something" },
#      "comment" => { "rating" => 1, "message" => "message about target!" }
#   }
#
post '/rate.json' do
  data = JSON.parse(request[:request])
  target = Target.find_or_create(data["target"])
  Comment.create(data["comment"].merge(:target_id => target.id))
  { :success => true, :request => request[:request] }.to_json
end

