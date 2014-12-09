# ServiceFactory

IOC container

## Installation

Add this line to your application's Gemfile:

    gem 'service_factory'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install service_factory

## Usage

1. Create service_factory.rb in config/initializers directory

```ruby
ServiceFactory.register do
  user_info UserInfo
  remote_data_service do |url|
    RemoteData.new(url)
  end

  env :test, :development do
    user_info Fake::UserInfo
  end

  memoize do
    memoized_info { costly_operation }
    memoized_class BigFatClass
  end
end
```

2. Then you can use it

```ruby
ServiceFactory.user_info("John Dou") #Same as UserInfo.new("John Dou") or Fake::UserInfo.new("John Dou")
ServiceFactory.remote_data_service("http://service.com") #Same as RemoteData.new("http://service.com")
ServiceFactory.memoized_info #Runs only once
```

See spec/service_factory_spec.rb for the full list of features

3. You can also use rspec-mock with this factory

```ruby
ServiceFactory.should_receive(:user_info).with("John Dou").and_return(double(:user_info, address: "baker street"))
```

4. Sometimes runing rails in development (for example, using `rails s`) lead to empty factory after reloading. To prevent this add code to config/environment/development.rb

```ruby
ActionDispatch::Reloader.to_prepare do
  load Rails.root.join('config/initializers/implementation.rb')
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
