require 'spec_helper'

require 'fixtures/human'

describe Switcher do

  describe "Basic functionality" do
    people = Human.new

    it "should switch to state with option" do
      people.go_to_school!
      people.state.should eq(:scholar)
    end

    it "should switch to state by internal condition" do
      people.finish_school!(2)
      people.state.should eq(:worker)
    end

    it "should have before and after callbacks" do
      people.full_age!(100)
      people.fight!(true)

      people.state.should eq(:civil)
      people.easy_to_fight.should be_true
      people.honor.should eq(100)
    end

    it "can prevent switch" do
      people.find_job!(false)
      people.state.should eq(:civil)
    end

    it "and can not" do
      people.find_job!(true)
      people.state.should eq(:manager)
    end

    it "can detect possibility to switch" do
      people.can_fight?.should be_false
      people.can_die?.should   be_true
    end

    it "should remember previous state" do
      people.state_prev.should eq(:civil)
    end

    it "should have state predicate" do
      people.manager?.should be_true
      people.civil?.should   be_false
    end
  end

end