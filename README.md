# MITIE Ruby

[MITIE](https://github.com/mit-nlp/MITIE) - named-entity recognition and binary relation detection - for Ruby

- Finds people, organizations, and locations in text
- Detects relationships between entities, like `PERSON` was born in `LOCATION`

[![Build Status](https://github.com/ankane/mitie-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/mitie-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "mitie"
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
doc = model.doc("Nat works at GitHub in San Francisco")
```

Get entities

```ruby
doc.entities
```

This returns

```ruby
[
  {text: "Nat",           tag: "PERSON",       score: 0.3112371212688382, offset: 0},
  {text: "GitHub",        tag: "ORGANIZATION", score: 0.5660115198329334, offset: 13},
  {text: "San Francisco", tag: "LOCATION",     score: 1.3890524313885309, offset: 23}
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

## Training [unreleased]

Load an NER model into a trainer

```ruby
trainer = Mitie::NERTrainer.new("total_word_feature_extractor.dat")
```

Create training instances

```ruby
instance = Mitie::NERTrainingInstance.new(["Kickstarter", "is", "headquartered", "in", "New", "York"])
instance.add_entity(0..0, "organization") # Kickstarter
instance.add_entity(4..5, "location")     # New York
```

Add the training instances to the trainer

```ruby
trainer.add(instance)
```

Train the model

```ruby
model = trainer.train
```

Save the model

```ruby
model.save_to_disk("ner_model.dat")
```

## Binary Relation Detection

Detect relationships betweens two entities, like:

- `PERSON` was born in `LOCATION`
- `ORGANIZATION` was founded in `LOCATION`
- `FILM` was directed by `PERSON`

There are 21 detectors for English. You can find them in the `binary_relations` directory in the model download.

Load a detector

```ruby
detector = Mitie::BinaryRelationDetector.new("rel_classifier_organization.organization.place_founded.svm")
```

And create a document

```ruby
doc = model.doc("Shopify was founded in Ottawa")
```

Get relations

```ruby
detector.relations(doc)
```

This returns

```ruby
[{first: "Shopify", second: "Ottawa", score: 0.17649169745814464}]
```

## History

View the [changelog](https://github.com/ankane/mitie-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/mitie-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/mitie-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/mitie-ruby.git
cd mitie-ruby
bundle install
bundle exec rake vendor:all

export MITIE_MODELS_PATH=path/to/MITIE-models/english
bundle exec rake test
```
