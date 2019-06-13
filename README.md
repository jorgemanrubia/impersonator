# Impersonator

Impersonator is a Ruby library to record and replay object interactions. 

When testing, you often find services that are expensive to invoke and you need to use a [double](https://martinfowler.com/bliki/TestDouble.html) instead. Creating stubs and mocks for simple scenarios is easy but, for complex interactions, things get messy fast. Stubbing elaborated canned response and mocking multiple expectations quickly degenerates in brittle tests that are hard to write and maintain.

Impersonator comes to the rescue. Given any object and a list of methods to impersonate:

- The first time each method is invoked, it will record its invocations, including passed arguments, return values and yielded values. This is known as *record mode*.
- The next times, it will reproduce the recorded values and will validate that the method was invoked with the same arguments, in certain order and the exact number of times. This is known as *replay mode*.

Impersonator only focus on validating invocation signature and reproducing return values, which is perfect for many services. It won't work for services that trigger additional logic that is relevant to the test (e.g: if the method sends an email, the impersonated method won't send it). 

Familiar with [VCR](https://github.com/vcr/vcr)? Impersonator is like VCR but for ruby objects instead of HTTP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'impersonator', group: :test
```

And then execute:

    $ bundle

## Usage

```ruby
class Calculator
  def sum(number_1, number_2)
    @invoked = true
    number_1 + number_2
  end
  
  def invoked?
    @invoked
  end
end

real_calculator = Calculator.new
impersonated_calculator = Impersonator.impersonate(real_calculator, :sum)

# The first time it records...
Impersonator.recording('calculator sum') do
	impersonated_calculator.sum(2, 3) # 5
  real_calculator.invoked? # true
end

# The next time it replays...
Impersonator.recording('calculator sum') do
	impersonated_calculator.sum(2, 3) # 5
  real_calculator.invoked? # false
end
```

Typically you will use `impersonate` for testing, so this is how your test will look:

```ruby
...
def setup
  real_calculator = Calculator.new
  @calculator = Impersonator.impersonate(real_calculator, :sum)
end  

# The second time the test runs, impersonator will replay the
# recorded results
test 'sums the numbers' do
  assert_equal 4,   @calculator.sum(2, 3)
end  
...
```

### Impersonate certain methods only

Use `Impersonator#impersonate` to impersonate certain methods. At replay time, the impersonated object will delegate to the real objects all the methods except the impersonated ones. 

```ruby
real_calculator = Calculator.new
impersonator = Impersonator.impersonate(real_calculator, :sum)
```

In this case, in replay mode, `Calculator` gets instantiated normally and any method other than `#sum`  will be delegated to `real_calculator`.

Impersonated methods will record and replay:

- Arguments
- Return values
- Yielded values

### Impersonate the whole object (generate double)

Sometimes, creating an object is not viable at test time. For these cases, you can use `Impersonate#impersonate_double`. It will take a list of methods to impersonate and a block responsible of instantiating the object in record mode. In replay mode, it will generate a double on the fly that only respond to the list of methods to impersonate.

```ruby
impersonator = Impersonator.impersonate_double(:sum) { Calculator.new }
```

In this case, `Calculator.new` will not be executed in replay mode. But the generated double will only respond to `sum`.

## Configuration

### Recordings path



### Ignore arguments

### Configuring attributes to record

### Disabling

### Rspec configuration

## Thanks

- This library was heavily inspired by [VCR](https://github.com/vcr/vcr). A solution that blown my mind years ago and that I have used since then.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jorgemanrubia/impersonator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).`
