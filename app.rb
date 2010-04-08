# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'sinatra_more/markup_plugin'
require 'active_support'

require 'sequel'

require 'json'

class App < Sinatra::Base
  register SinatraMore::MarkupPlugin

  set :public, File.join(File.dirname(__FILE__), 'public')

  db_config = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config/database.yml')))
  configure :development do
    Sequel.connect(db_config[:development])
  end
  configure :test do
    Sequel.connect(db_config[:test])
  end
  configure :production do
    Sequel.connect(db_config[:production])
  end

  require 'models/target.rb'
  require 'models/comment.rb'

  helpers do
    include Rack::Utils; alias_method :h, :escape_html
  end

  get '/style.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :style
  end

  get '/index.rss' do
    content_type 'application/xml', :charset => 'utf-8'
    @comments = Comment.order_by(:updated_at.desc).limit(200).all
    builder :index
  end

  get '/' do
    @targets = Target.order_by(:updated_at).all
    haml :index
  end

  get '/target/:id.rss' do
    @target = Target.find(:id => params[:id])
    @comments = Comment.filter(:target_id => @target.id).order_by(:updated_at).limit(200).all
    content_type 'application/xml', :charset => 'utf-8'
    builder :show
  end

  get '/target/:id' do
    @target = Target.find(:id => params[:id])
    if request.xhr?
      haml :show, :layout => false
    else
      haml :show
    end
  end

  get '/uri' do
    @target = Target.find(:uri => params[:uri])
    # MEMO request.xhr? で場合分けしたいけど jQuery.getJSON だと request.xhr? が true にならない。
    content_type :json
    "#{params[:callback]}(#{@target.comments.map(&:to_hash_for_display).to_json});"
  end

  get '/rate' do
    haml :rate
  end

  #
  # params[:uri]
  # params[:name]
  # params[:email]
  # params[:rating]
  # params[:message]
  #
  post '/rate.json' do
    begin
      target = Target.find_or_create(:uri => params[:uri])
      Comment.create(:target_id => target.id,
                     :name      => params[:name],
                     :email     => params[:email],
                     :rating    => params[:rating],
                     :message   => params[:message])
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

