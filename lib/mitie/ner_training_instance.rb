module Mitie
  class NERTrainingInstance
    def initialize(tokens)
      tokens_pointer = Utils.array_to_pointer(tokens)

      @pointer = FFI.mitie_create_ner_training_instance(tokens_pointer)
      raise "Unable to create ner_training_instance. Probably ran out of RAM." if @pointer.null?

      ObjectSpace.define_finalizer(self, self.class.finalize(@pointer))
    end

    attr_reader :pointer

    def add_entity(range, label)
      if range.none? || range.end >= num_tokens || range.begin < 0
        raise ArgumentError, "Invalid range given to `add_entity'"
      end

      raise ArgumentError, "oops, it overlaps" if overlaps_any_entity?(range)

      unless FFI.mitie_add_ner_training_entity(@pointer, range.begin, range.size, label).zero?
        raise "Unable to add entity to training instance. Probably ran out of RAM."
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
        raise ArgumentError, "Invalid range given to `overlaps_any_entity?'"
      end

      FFI.mitie_overlaps_any_entity(@pointer, range.begin, range.size) == 1
    end

    # :nodoc:
    def self.finalize(pointer)
      proc { FFI.mitie_free(pointer) }
    end
  end
end
