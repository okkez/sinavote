# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'sinatra_more/markup_plugin'
require 'active_support'

require 'sequel'
Sequel.sqlite('db/development.db')
require 'models/target.rb'
require 'models/comment.rb'

require 'json'

class App < Sinatra::Base
  register SinatraMore::MarkupPlugin

  set :public, File.join(File.dirname(__FILE__), 'public')

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

  get '/rate' do
    haml :rate
  end

  #
  # params[:uri]
  # params[:rating]
  # params[:message]
  #
  post '/rate.json' do
    begin
      target = Target.find_or_create(:uri => params[:uri])
      Comment.create(:target_id => target.id,
                     :rating => params[:rating],
                     :message => params[:message])
      content_type 'application/json', :charset => 'utf-8'
      { :success => true, :request => params }.to_json
    rescue => ex
      message = '%s : %s' % [ex.class.to_s, ex.message]
      content_type 'application/json', :charset => 'utf-8'
      status 500
      { :success => false, :request => params, :message => message }.to_json
    end
  end
end

