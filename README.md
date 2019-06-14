# Impersonator

Impersonator is a Ruby library to record and replay object interactions. 

When testing, you often find services that are expensive to invoke and you need to use a [double](https://martinfowler.com/bliki/TestDouble.html) instead. Creating stubs and mocks for simple scenarios is easy but, for complex interactions, things get messy fast. Stubbing elaborated canned response and orchestrating multiple expectations quickly degenerates in brittle tests that are hard to write and maintain.

Impersonator comes to the rescue. Given any object and a list of methods to impersonate:

- The first time each method is invoked, it will record its invocations, including passed arguments, return values and yielded values. This is known as *record mode*.
- The next times, it will reproduce the recorded values and will validate that the method was invoked with the same arguments, in certain order and the exact number of times. This is known as *replay mode*.

Impersonator only focuses on validating invocation signature and reproducing output values, which is perfect for many services. It won't work for services that trigger additional logic that is relevant to the test (e.g: if the method sends an email, the impersonated method won't send it). 

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

# The first time it records...
Impersonator.recording('calculator sum') do
  impersonated_calculator = Impersonator.impersonate(real_calculator, :sum)
  impersonated_calculator.sum(2, 3) # 5
  real_calculator.invoked? # true
end

# The next time it replays...
Impersonator.recording('calculator sum') do
  impersonated_calculator = Impersonator.impersonate(real_calculator, :sum)
  impersonated_calculator.sum(2, 3) # 5
  real_calculator.invoked? # false
end
```

Typically you will use `impersonate` for testing, so this is how your test will look:

```ruby
...
def setup
  real_calculator = Calculator.new
end

# The second time the test runs, impersonator will replay the
# recorded results
test 'sums the numbers' do
  Impersonator.recording('calculator sum') do
    @calculator = Impersonator.impersonate(real_calculator, :sum)
    assert_equal 5, @calculator.sum(2, 3)
  end
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

### Impersonate the whole object

Sometimes, creating the real object is not viable at replay time. For these cases, you can use `Impersonate#impersonate_double`. It will take a list of methods to impersonate and a block responsible of instantiating the object in record mode. In replay mode, it will generate a double on the fly that only responds to the list of methods to impersonate.

```ruby
impersonator = Impersonator.impersonate_double(:sum) { Calculator.new }
```

In this case, `Calculator.new` will not be executed in replay mode. But the generated double will only implement `sum`.

## Configuration

### Recordings path

`Impersonator` works by recording method invocations in `YAML` format. By default, recordings are saved in:

- `test/recordings` if a `test` folder is present in the project
- `spec/recordings` if a `spec` folder is present in the project

You can configure this path with:

```ruby
Impersonator.configure do |config|
  config.recordings_path = 'my/own/recording/path'
end
```

### Ignore arguments when matching methods

By default, to determine if a method invocation was right, the list of arguments will be matched with `==`. You can configure how this work by providing a list of argument indexes to ignore.

```ruby
Impersonator.recording('test recording', disabled: true) do
  # ...
end
impersonator = Impersonator.impersonate(real_calculator, :sum)
impersonator.configure_method_matching_for(:sum) do |config|
  config.ignore_arguments_at 0
end

# Now the first parameter of #sum will be ignored.
#
# In record mode:
impersonator.sum(1, 2) # 3

# In replay mode
impersonator.sum(9999, 2) # will still return 3 and won't fail because the first argument is ignored
```

### Disabling

You can disable `impersonator` by passing `disable: true` to `Impersonator.recording`:

```ruby
Impersonator.recording('test recording', disabled: true) do
  # ...
end
```

This will effectively force record mode in all times. It will save the recordings but it will never use them.

### Configuring attributes to serialize

`Impersonator` relies on Ruby standard `YAML` library for serializing/deserializing data. It works with simple attributes, arrays, hashes and objects which attributes are serializable in a recurring way. This means that you don't have to care when interchanging value objects, which is a common scenario when impersonating RPC-like clients.

However, there are some types, like `Proc`, anonymous classes  or `IO` classes like `File`, that will make the serialization process fail. You can customize which attributes are serialized by overridding `init_with` and `encode_with` in the class you want to serialize. You will typically exclude the problematic attributes by including only the compatible ones.

```ruby
class MyClass
  # ...
  
  def init_with(coder)
    self.name = coder['name']
  end

  def encode_with(coder)
    coder['name'] = name
  end
end
```

### RSpec configuration

`Impersonator` is test-framework agnostic. If you are using [RSpec](https://rspec.info), you can configure an `around` hook that will start a recording session automatically for each example that has a `impersonator` tag:

```ruby
RSpec.configure do |config|
  config.around(:example, :impersonator) do |example|
    Impersonator.recording(example.full_description) do
      example.run
    end
  end
end
```

Now you can just tag your tests with `impersonator` and an implicit recording named after the example will be available automatically, so you don't have to invoke `Impersonator.recording` anymore.

```ruby
describe Calculator, impersonator: do
  it 'sums numbers' do
    # there is an implicit recording stored in 'calculator-sums-	numbers.yaml'
    impersonator = Impersonator.impersonate(real_calculator, :sum)
    expect(impersonator.sum(1, 2)).to eq(3)
  end
end
```

## Thanks

- This library was heavily inspired by [VCR](https://github.com/vcr/vcr). A gem that blown my mind years ago and that has been in my toolbox since then.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jorgemanrubia/impersonator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).`
