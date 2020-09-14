# MITIE

[MITIE](https://github.com/mit-nlp/MITIE) - named-entity recognition - for Ruby

[![Build Status](https://travis-ci.org/ankane/mitie.svg?branch=master)](https://travis-ci.org/ankane/mitie)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'mitie'
```

And download the pre-trained model for your language:

- [English](https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v0.2.tar.bz2)
- [Spanish](https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v0.2-Spanish.zip)
- [German](https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v0.2-German.tar.bz2)

## Getting Started

Get your text

```ruby
text = "Nat Friedman is the CEO of GitHub, which is headquartered in San Francisco"
```

Load an NER model

```ruby
model = Mitie::NER.new("ner_model.dat")
```

Get entities

```ruby
model.entities(text)
```

This returns

```ruby
[
  {text: "Nat Friedman",  tag: "PERSON",       score: 1.099661347535191, offset: 0},
  {text: "GitHub",        tag: "ORGANIZATION", score: 0.344641651251650, offset: 27},
  {text: "San Francisco", tag: "LOCATION",     score: 1.428241888939011, offset: 61}
]
```

Get tokens

```ruby
model.tokens(text)
```

Get tokens and their offset

```ruby
model.tokens_with_offset(text)
```

Get all tags for a model

```ruby
model.tags
```

## History

View the [changelog](https://github.com/ankane/mitie/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/mitie/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/mitie/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/mitie.git
cd mitie
bundle install
bundle exec rake vendor:all
MITIE_NER_PATH=path/to/ner_model.dat bundle exec rake test
```
