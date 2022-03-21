module Mitie
  class NERTrainingInstance
    attr_reader :pointer

    def initialize(tokens)
      tokens_pointer = Utils.array_to_pointer(tokens)

      @pointer = FFI.mitie_create_ner_training_instance(tokens_pointer)
      raise Error, "Unable to create training instance. Probably ran out of RAM." if @pointer.null?

      ObjectSpace.define_finalizer(self, self.class.finalize(@pointer))
    end

    def add_entity(range, label)
      if range.none? || range.end >= num_tokens || range.begin < 0
        raise ArgumentError, "Invalid range"
      end

      raise ArgumentError, "Range overlaps existing entity" if overlaps_any_entity?(range)

      unless FFI.mitie_add_ner_training_entity(@pointer, range.begin, range.size, label).zero?
        raise Error, "Unable to add entity to training instance. Probably ran out of RAM."
      end

      nil
    end

    def num_entities
      FFI.mitie_ner_training_instance_num_entities(@pointer)
    end

    def num_tokens
      FFI.mitie_ner_training_instance_num_tokens(@pointer)
    end

    def overlaps_any_entity?(range)
      if range.none? || range.max >= num_tokens
        raise ArgumentError, "Invalid range"
      end

      FFI.mitie_overlaps_any_entity(@pointer, range.begin, range.size) == 1
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end
  end
end
