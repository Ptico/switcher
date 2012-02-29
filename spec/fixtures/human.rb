class Human
  include Switcher

  def initialize
    @easy_to_fight = false
    @honor = 0
  end

  attr_reader :easy_to_fight, :honor

  switcher :state do
    state :newborn do
      on :go_to_school, switch_to: :scholar
    end

    state :scholar do
      on :finish_school do |ev, exams|
        if pass?(exams)
          ev.switch_to :student
        else
          ev.switch_to :worker
        end
      end
    end

    state :student do
      on :finish_university do |ev, exams|
        if pass?(exams)
          ev.switch_to :manager
        else
          ev.switch_to :soldier
        end
      end
    end

    state :worker do
      on :full_age do |ev, money|
        if enough?(money)
          ev.switch_to :manager
        else
          ev.switch_to :soldier
        end
      end
    end

    state :soldier do
      on :die, switch_to: :dead

      before :fight do |ev, learn|
        if hard_to?(learn)
          @easy_to_fight = true
        end
      end

      on :fight do |ev|
        if @easy_to_fight
          ev.switch_to :civil
        else
          rand(2).even? ? ev.switch_to(:dead) : ev.switch_to(:civil)
        end
      end

      after :fight do
        if self.state == :civil
          @honor = 100
        end
      end
    end

    state :civil do
      on :find_job, switch_to: :manager do |ev, cv|
        ev.restrict unless cv
      end
    end

    state :manager do
      on :die, switch_to: :dead
    end
  end

  def pass?(score)
    score > 3
  end

  def enough?(num)
    num > 9000
  end

  def hard_to?(learn=false)
    !!learn
  end
end