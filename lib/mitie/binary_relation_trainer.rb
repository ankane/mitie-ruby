module Mitie
  class BinaryRelationTrainer
    def initialize(name, ner)
      @pointer = FFI.mitie_create_binary_relation_trainer(name, ner.pointer)

      ObjectSpace.define_finalizer(self, self.class.finalize(@pointer))
    end

    def add_positive_binary_relation(tokens, first_range, second_range)
      tokens_pointer = Utils.array_to_pointer(tokens)
      status = FFI.mitie_add_positive_binary_relation(@pointer, tokens_pointer, first_range.begin, first_range.size, second_range.begin, second_range.size)
      if status != 0
        raise Error, "Unable to add binary relation"
      end
    end

    def add_negative_binary_relation(tokens, first_range, second_range)
      tokens_pointer = Utils.array_to_pointer(tokens)
      status = FFI.mitie_add_negative_binary_relation(@pointer, tokens_pointer, first_range.begin, first_range.size, second_range.begin, second_range.size)
      if status != 0
        raise Error, "Unable to add binary relation"
      end
    end

    def beta
      FFI.mitie_binary_relation_trainer_get_beta(@pointer)
    end

    def beta=(value)
      raise ArgumentError, "beta must be greater than or equal to zero" unless value >= 0

      FFI.mitie_binary_relation_trainer_set_beta(@pointer, value)
    end

    def num_threads
      FFI.mitie_binary_relation_trainer_get_num_threads(@pointer)
    end

    def num_threads=(value)
      FFI.mitie_binary_relation_trainer_set_num_threads(@pointer, value)
    end

    def num_positive_examples
      FFI.mitie_binary_relation_trainer_num_positive_examples(@pointer)
    end

    def num_negative_examples
      FFI.mitie_binary_relation_trainer_num_negative_examples(@pointer)
    end

    def train
      detector = FFI.mitie_train_binary_relation_detector(@pointer)

      raise Error, "Unable to create binary relation detector. Probably ran out of RAM." if detector.null?

      Mitie::BinaryRelationDetector.new(pointer: detector)
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end
  end
end
