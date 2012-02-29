require 'spec_helper'

require 'fixtures/human'
require 'fixtures/car'

describe Switcher do

  describe "Basic functionality" do
    person = Human.new

    it "should have initial state" do
      person.state.should eq(:newborn)
    end

    it "should switch to state with option" do
      person.go_to_school!

      person.state.should eq(:scholar)
    end

    it "should switch to state by internal condition" do
      person.finish_school!(2)

      person.state.should eq(:worker)
    end

    it "should have before and after callbacks" do
      person.full_age!(100)
      person.fight!(true)

      person.state.should eq(:civil)
      person.easy_to_fight.should be_true
      person.honor.should eq(100)
    end

    it "can prevent switch" do
      person.find_job!(false)

      person.state.should eq(:civil)
    end

    it "and can not" do
      person.find_job!(true)

      person.state.should eq(:manager)
    end

    it "can detect possibility to switch" do
      person.can_fight?.should be_false
      person.can_die?.should   be_true
    end

    it "should remember previous state" do
      person.state_prev.should eq(:civil)
    end

    it "should have state predicate" do
      person.state_manager?.should be_true
      person.state_civil?.should   be_false
    end
  end

  describe "Multiple states" do
    car = Car.new

    it "should have different states" do
      car.state.should    eq(:new)
      car.movement.should eq(:stands)
    end

    it "should switch states" do
      car.buy!

      car.state.should    eq(:buyed)
      car.movement.should eq(:stands)
    end

    it "should have cross-stated events" do
      car.start!

      car.state.should    eq(:used)
      car.movement.should eq(:moves)
    end

    it "should remember previous states" do
      car.state_prev.should    eq(:buyed)
      car.movement_prev.should eq(:stands)
    end

    it "should have state predicates" do
      car.state_used?.should be_true
      car.state_new?.should  be_false

      car.movement_moves?.should  be_true
      car.movement_stands?.should be_false
    end
  end

  describe "Multiple instances" do
    car_one = Car.new
    car_two = Car.new

    it "should work independent" do
      car_one.buy!

      car_two.state.should eq(:new)
    end
  end
end