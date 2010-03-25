require 'spec_helper'
require 'app'
require 'db/schema'

describe App do
  include Rack::Test::Methods

  before :all do
    AppSchema.setup
    ::Object.__send__(:remove_const, :Target)
    ::Object.__send__(:remove_const, :Comment)
    load 'models/target.rb'
    load 'models/comment.rb'
  end

  after :all do
    File.delete 'db/development.db' if File.exist? 'db/development.db'
  end

  after do
    Target.delete
    Comment.delete
  end

  def app
    App
  end

  describe "GET '/'" do
    before do
      get '/'
    end
    it{ last_response.should be_ok }
  end

  describe "POST 'rate.json'" do
    describe "with no parameters" do
      before do
        post 'rate.json'
      end
      it{ last_response.should_not be_ok }
      it{ last_response.status.should == 500 }
      it{ JSON.parse(last_response.body)["success"].should_not be_true }
    end
    describe "with some parameters" do
      before do
        post('rate.json',
             :request => {
               :target => { :uri => "http://example.com/path/to/target" },
               :comment => { :rating => 1, :message => "not so bad!" },
             }.to_json)
      end
      it{ last_response.should be_ok }
      it{ JSON.parse(last_response.body)["success"].should be_true }
    end
    describe "with same request" do
      before do
        post('rate.json',
             :request => {
               :target => { :uri => "http://example.com/path/to/target" },
               :comment => { :rating => 1, :message => "not so bad!" },
             }.to_json)
        post('rate.json',
             :request => {
               :target => { :uri => "http://example.com/path/to/target" },
               :comment => { :rating => 2, :message => "not so bad!" },
             }.to_json)
      end
      it{ last_response.should be_ok }
      it{ JSON.parse(last_response.body)["success"].should be_true }
    end
  end
end
