class Airbag
  include Switcher::Object

  def initialize
    @crashed_from = nil
  end

  attr_reader :crashed_from

  switcher :state do
    state :idle do
      on :crash, switch_to: :deployed do |ev|
        @crashed_from = ev.target
      end
    end

    state :deployed
  end
end