Switcher is lightweight event-driven state machine.

## Basic usage:

```ruby
class Package
  include Switcher::Object

  def initialize(weight)
    @sent_weight = weight.to_f
    @tracking_number = nil
  end

  switcher :delivery do
    state :requested do
      on :send, switch_to: :sent do |ev, num|
        @tracking_number = num
      end
    end

    state :sent do
      before :receive, call: :check_number

      on :receive do |ev, number, weight|
        if weight < (@weight - 0.3)
          ev.switch_to :stolen
        else
          ev.switch_to :received
        end
      end

      after :receive do |ev|
        unpack if delivery_received?
      end

      on :miss, switch_to: :missed
    end

    state :received
    state :stolen
    state :missed
  end

  def check_number(ev, number, weight)
    ev.stop if number.to_s != @tracking_number
  end

  def unpack
    puts "TADA!"
  end
end

package = Package.new(4.2)

package.delivery # => :requested
package.can_send? # => true
package.send! "AB123456CD"
package.delivery # => :sent
package.receive!(3.5, "CD654321AB")
package.delivery # => :sent
package.receive!(4.1, "AB123456CD")
# > TADA!

package.delivery # => :received
package.delivery_prev # => :sent
package.delivery_received? # => true
package.can_miss? # => false
```

## Usage with Active Record:

```ruby
class User < ActiveRecord::Base
  include Switcher::ActiveRecord

  switcher :membership do
    state :guest do
      on :approve, switch_to: :member
    end
    state :member do
      on :ban, switch_to: :banned do |ev, reason|
        ev.stop unless reason
        ban_reason = reason
      end
    end
    state :banned do
      on :unban, switch_to: :member
      after :unban do
        ban_reason = nil
      end
    end
  end
end

user = User.find(5)
user.ban! "Stupid bastard"
user.membership # => :banned
user.save
```

## More examples:

* [Wiki](https://github.com/Ptico/switcher/wiki)
* Specs in spec/

## TODO:

* 1.8 compat
* Write README
* Refactoring
* Events without state
* Ability to define validations, associations etc. in state (ability to call static methods from object)

## Adapters TODO:

* ActiveModel
* Virtus
* Mongoid