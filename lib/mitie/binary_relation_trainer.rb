module Mitie
  class BinaryRelationTrainer
    def initialize(ner, name: "")
      @pointer = FFI.mitie_create_binary_relation_trainer(+name, ner.pointer)
      @pointer.free = FFI["mitie_free"]
    end

    def add_positive_binary_relation(tokens, range1, range2)
      check_add(tokens, range1, range2)

      tokens_pointer = Utils.array_to_pointer(tokens)
      status = FFI.mitie_add_positive_binary_relation(@pointer, tokens_pointer, range1.begin, range1.size, range2.begin, range2.size)
      if status != 0
        raise Error, "Unable to add binary relation"
      end
    end

    def add_negative_binary_relation(tokens, range1, range2)
      check_add(tokens, range1, range2)

      tokens_pointer = Utils.array_to_pointer(tokens)
      status = FFI.mitie_add_negative_binary_relation(@pointer, tokens_pointer, range1.begin, range1.size, range2.begin, range2.size)
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
      if num_positive_examples + num_negative_examples == 0
        raise Error, "You can't call train() on an empty trainer"
      end

      detector = FFI.mitie_train_binary_relation_detector(@pointer)

      raise Error, "Unable to create binary relation detector. Probably ran out of RAM." if detector.null?

      detector.free = FFI["mitie_free"]

      Mitie::BinaryRelationDetector.new(pointer: detector)
    end

    private

    def check_add(tokens, range1, range2)
      Utils.check_range(range1, tokens.size)
      Utils.check_range(range2, tokens.size)

      if entities_overlap?(range1, range2)
        raise ArgumentError, "Entities overlap"
      end
    end

    def entities_overlap?(range1, range2)
      FFI.mitie_entities_overlap(range1.begin, range1.size, range2.begin, range2.size) == 1
    end
  end
end
