# MITIE

[MITIE](https://github.com/mit-nlp/MITIE) - named-entity recognition and binary relation detection - for Ruby

- Finds people, organization, and locations in text
- Detects relationships between entities, like `PERSON` was born in `LOCATION`

[![Build Status](https://travis-ci.org/ankane/mitie.svg?branch=master)](https://travis-ci.org/ankane/mitie) [![Build status](https://ci.appveyor.com/api/projects/status/stc89tc57xfva451/branch/master?svg=true)](https://ci.appveyor.com/project/ankane/mitie/branch/master)

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

Load an NER model

```ruby
model = Mitie::NER.new("ner_model.dat")
```

Create a document

```ruby
doc = model.doc("Nat Friedman is the CEO of GitHub, which is headquartered in San Francisco")
```

Get entities

```ruby
doc.entities
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
doc.tokens
```

Get tokens and their offset

```ruby
doc.tokens_with_offset
```

Get all tags for a model

```ruby
model.tags
```

## Binary Relation Detection

Detect relationships betweens two entities, like:

- `PERSON` was born in `LOCATION`
- `ORGANIZATION` was founded in `LOCATION`
- `FILM` was directed by `PERSON`

Create a detector

```ruby
detector = Mitie::BinaryRelationDetector.new("rel_classifier_film.film.directed_by.svm")
```

And a document

```ruby
doc = model.doc("The Shawshank Redemption was directed by Frank Darabont")
```

Get binary relations

```ruby
detector.binary_relations(doc)
```

This returns

```ruby
[{first: "Shawshank Redemption", second: "Frank Darabont", score: 1.124211742912441}]
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

export MITIE_MODELS_PATH=path/to/MITIE-models/english
bundle exec rake test
```
