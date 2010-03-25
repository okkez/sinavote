# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'sinatra_more/markup_plugin'
require 'active_support'

require 'sequel'
Sequel.sqlite('db/development.db')
require 'models/target.rb'
require 'models/comment.rb'

require 'json'

class App < Sinatra::Base
  register SinatraMore::MarkupPlugin

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

  get '/target/:id' do
    @target = Target.find(params[:id])
    haml :show
  end

  #
  # クエリパラメータの request に以下のような JSON データをセットする
  #
  #   {
  #      "target" => { "uri" => "http://example.com/path/to/something" },
  #      "comment" => { "rating" => 1, "message" => "message about target!" }
  #   }
  #
  post '/rate.json' do
    begin
      data = JSON.parse(params[:request])
      target = Target.find_or_create(data["target"].symbolize_keys)
      Comment.create(data["comment"].merge(:target_id => target.id).symbolize_keys)
      content_type 'application/json', :charset => 'utf-8'
      { :success => true, :request => params[:request] }.to_json
    rescue => ex
      message = '%s : %s' % [ex.class.to_s, ex.message]
      content_type 'application/json', :charset => 'utf-8'
      status 500
      { :success => false, :request => params[:request], :message => message }.to_json
    end
  end
end

