module Mitie
  class NERTrainer
    def initialize(filename)
      raise ArgumentError, "File `#{filename}' does not exist" unless File.exist?(filename)
      @pointer = FFI.mitie_create_ner_trainer(filename)

      ObjectSpace.define_finalizer(self, self.class.finalize(@pointer))
    end

    def add(instance)
      FFI.mitie_add_ner_training_instance(@pointer, instance.pointer)
    end

    def beta
      FFI.mitie_ner_trainer_get_beta(@pointer)
    end

    def beta=(value)
      raise ArgumentError, "beta must be greater than or equal to zero" unless value >= 0

      FFI.mitie_ner_trainer_set_beta(@pointer, value)
      nil
    end

    def num_threads
      FFI.mitie_ner_trainer_get_num_threads(@pointer)
    end

    def num_threads=(value)
      FFI.mitie_ner_trainer_set_num_threads(@pointer, value)
      nil
    end

    def size
      FFI.mitie_ner_trainer_size(@pointer)
    end

    def train
      raise "You can't call train() on an empty trainer" if size.zero?

      extractor = FFI.mitie_train_named_entity_extractor(@pointer)

      raise "Unable to create named entity extractor. Probably ran out of RAM." if extractor.null?

      Mitie::NER.new(pointer: extractor)
    end

    # :nodoc:
    def self.finalize(pointer)
      proc { FFI.mitie_free(pointer) }
    end
  end
end
