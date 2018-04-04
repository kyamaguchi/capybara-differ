# Capybara::Refactoring

Print the diff of snapshots with Capybara.
This will help refactoring of views.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-refactoring'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-refactoring

## Usage

In your system test(feature spec)

```
page.check_page('name_of_snapshot', selector: 'table')
```

You can get the diff from the history of `Capybara:Session#save_page`.

In this example(when you add class to table header),  
you will see the diff of latest snapshot and the first snapshot in _tmp/capybara/name_of_snapshot/_ .

```
       <th class="id">
         ID
       </th>
-      <th class="name">
+      <th class="name foo">
         Name
       </th>
```

You can reset the target snapshot by removing files in _tmp/capybara/name_of_snapshot/_ .  
Or remove the directory of snapshots.

## TODO

- Add an option to compare with the previous snapshot
- Add an option to suppress log
- Others

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/capybara-refactoring.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
