# Yard::Rails::Plugin

This plugin for [Yard](http://yardoc.org) permits to generate the documentation about a [Rails](http://rubyonrails.org) project.

This means to handle in the correct way things such **models**, **controllers**, **routes** and so on.

At now this plugin manages:

- Routes
  - creates a summary file
  - adds to each controller and action its routes
- Controller Params
  - adds to each action a list of params taken

You are more than invited to contribute!

## Installation

For now this gem is available only through github so add this line to your application's Gemfile:

```bash
    gem 'yard_rails_plugin'
```

Execute:

```bash
    bundle
```

Then edit the file ```.yardopts``` with

```ruby
    "{lib,app}/**/*.rb" --plugin rails-plugin - tmp/routes.html
```

## Usage

Now you can execure yard doc with

```bash
    bundle exec yard
```
