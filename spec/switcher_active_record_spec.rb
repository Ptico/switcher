require 'spec_helper'
require 'active_record'
require 'fixtures/box'
require 'fileutils'

describe Switcher::ActiveRecord do
  before :all do
    FileUtils.rm("test.sqlite3") if File.exists?("test.sqlite3")

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "test.sqlite3")

    ActiveRecord::Schema.define do
      create_table :boxes do |t|
        t.string :type
        t.string :state
        t.string :state_prev
      end
    end
  end

  after :all do
    FileUtils.rm("test.sqlite3")
  end

  let(:box) do
    Box.new
  end

  it "should have initial state" do
    box.state.should eq(:requested)
  end

  it "should switch states" do
    box.produce!

    box.state.should eq(:produced)
  end

  it "should save states" do
    box.produce!
    box.save

    box.reload

    box.state.should eq(:produced)
  end

  it "should save previous states if possible" do
    box.produce!
    box.save

    box.reload

    box.state_prev.should eq(:requested)
  end

  it "should save last defined state" do
    box.produce!
    box.break!
    box.save

    box.reload

    box.state.should eq(:broken)
  end

  it "can detect possibility to switch" do
    box.can_produce?.should be_true
    box.can_break?.should   be_false
  end

  it "should have state predicate" do
    box.state_requested?.should be_true
    box.state_produced?.should  be_false
  end

  it "should force state" do
    box.state_force(:broken)
    box.save

    reloaded = Box.find(box.id)

    reloaded.state.should eq(:broken)
  end
end