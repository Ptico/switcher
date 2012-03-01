require 'active_record'

class Box < ActiveRecord::Base
  include Switcher

  switcher :state do
    state :requested do
      on :produce, switch_to: :produced
    end

    state :produced
  end

  def test
    x=2
    debugger
    x=1
  end
end