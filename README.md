# Faraday XML

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/gemhome/faraday-xml/ci)](https://github.com/gemhome/faraday-xml/actions?query=branch%3Amain)
[![Gem](https://img.shields.io/gem/v/faraday-xml.svg?style=flat-square)](https://rubygems.org/gems/faraday-xml)
[![License](https://img.shields.io/github/license/gemhome/faraday-xml.svg?style=flat-square)](LICENSE.md)

Faraday XML Middleware.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday-xml'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install faraday-xml
```

## Usage

```ruby
require 'faraday'
require 'faraday/xml'

conn = Faraday.new do |builder|
  builder.headers.update(
    "Accept" => "application/xml",
    "Content-Type" => "application/xml;charset=UTF-8",
  )
  # or builder.use Faraday::XML::Request
  builder.request :xml # encode Hash as XML
  # or builder.use Faraday::XML::Response
  builder.response :xml # decode response bodies from XML
end
```

There is also basic support for first class XML encoding/parsing

```ruby
require 'faraday'
require 'faraday/xml'
hash = { 'user' => { 'name' => 'Erik Michaels-Ober', 'screen_name' => 'sferik' } }
xml = '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>'

encoder = Faraday::XML::Encoder.build!(indent: 0)
encoder.encode(hash) == xml

parser = Faraday::XML::Parser.build!
parser.parse(xml) == hash
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `bin/test` to run the tests.

To install this gem onto your local machine, run `rake build`.

To release a new version, make a commit with a message such as "Bumped to 0.0.2" and then run `rake release`.
See how it works [here](https://bundler.io/guides/creating_gem.html#releasing-the-gem).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/gemhome/faraday-xml).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
