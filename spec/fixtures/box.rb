require 'active_record'

class Box < ActiveRecord::Base
  include Switcher::ActiveRecord

  switcher :state do
    state :requested do
      on :produce, switch_to: :produced
    end

    state :produced do
      on :break, switch_to: :broken
    end

    state :broken
  end
end