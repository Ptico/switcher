require 'spec_helper'
require 'active_record'
require 'fixtures/box'
require 'fileutils'

describe Switcher do
  before :all do
    FileUtils.rm("test.sqlite3") if File.exists?("test.sqlite3")

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "test.sqlite3")

    ActiveRecord::Schema.define do
      create_table :boxes do |t|
        t.string :type
        t.string :state
      end
    end
  end

  after :all do
    FileUtils.rm("test.sqlite3")
  end

  it "should have initial state" do
    box = Box.new
    box.state.should eq(:requested)
  end

  it "should switch states" do
    box = Box.new
    box.produce!

    box.state.should eq(:produced)
  end

  it "should save states" do
    box = Box.new

    box.produce!
    box.save

    Box.find(box.id).state.should eq(:produced)
  end
end