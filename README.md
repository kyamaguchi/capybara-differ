# Capybara::Differ

[![Gem Version](https://badge.fury.io/rb/capybara-differ.svg)](https://badge.fury.io/rb/capybara-differ)
[![Build Status](https://travis-ci.org/kyamaguchi/capybara-differ.svg?branch=master)](https://travis-ci.org/kyamaguchi/capybara-differ)

Print the diff of snapshots with Capybara.  
This will help refactoring of views.

## Idea

The main feature of this library is  **diffing beautified htmls**.

You cannot always get nice diffs with 'git diff' or 'diff' command.  
But this library gives them.  
This library try to remove the concerns on diff of whitespaces, linebreaks.

Expected use cases are

* Refactoring views of Rails app
    * Migration of erb -> haml
    * Integration with [datagrid](https://github.com/bogdan/datagrid)
* Tracking sites
    * visit -> save_page -> check_page

### Dependencies

* https://github.com/samg/diffy
* https://github.com/threedaymonk/htmlbeautifier

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-differ'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-differ

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

### Options

#### Compare with the previous version

By default, the target snapshot is the first version.

You can compare with the previous version with the following option

```
page.check_page('name_of_snapshot', compare_with: :previous, selector: 'table')
```

#### Diffy

This library depends on [diffy](https://github.com/samg/diffy)
You can pass the options for diffy something like 'context'.

```
page.check_page('name_of_snapshot', selector: 'table', diffy: {context: 3})
```

And you can change the format of output with diffy with 'format' option. (default :color)

```
page.check_page('name_of_snapshot', selector: 'table', diffy: {format: :html_simple})
```

## TODO

- Add an option to suppress log
- Others

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/capybara-differ.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
