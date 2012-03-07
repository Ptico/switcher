[![Build Status](https://secure.travis-ci.org/Ptico/switcher.png)](http://travis-ci.org/Ptico/switcher)

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
* [Specs](https://github.com/Ptico/switcher/tree/master/spec)

## TODO:

* 1.8 compat
* Refactoring
* Events without state
* Ability to define validations, associations etc. in state (ability to call static methods from object)

## Adapters TODO:

* ActiveModel
* Virtus
* Mongoid

## License

The modified MIT license

Copyright (c) 2012 Andrey Savchenko

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* Except as contained in this notice, the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.