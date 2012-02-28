class Car
  include Switcher::Machine

  switcher :state do
    state :new do
      on :buy, switch_to: :buyed
    end

    state :buyed do
      on :start, switch_to: :used
    end

    state :used do
      on :crash, switch_to: :damaged
    end

    state :damaged do
      on :repair, switch_to: :used
    end
  end

  switcher :movement do
    state :stands do
      on :start, switch_to: :moves
    end

    state :moves do
      on :stop, switch_to: :stands
    end
  end
end