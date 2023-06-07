module Mitie
  class NERTrainingInstance
    attr_reader :pointer

    def initialize(tokens)
      tokens_pointer = Utils.array_to_pointer(tokens)

      @pointer = FFI.mitie_create_ner_training_instance(tokens_pointer)
      raise Error, "Unable to create training instance. Probably ran out of RAM." if @pointer.null?
      @pointer.free = FFI["mitie_free"]
    end

    def add_entity(range, label)
      Utils.check_range(range, num_tokens)

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
      Utils.check_range(range, num_tokens)

      FFI.mitie_overlaps_any_entity(@pointer, range.begin, range.size) == 1
    end
  end
end
