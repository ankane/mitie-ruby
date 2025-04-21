module Mitie
  class TextCategorizerTrainer
    def initialize(filename)
      raise ArgumentError, "File does not exist" unless File.exist?(filename)
      @pointer = FFI.mitie_create_text_categorizer_trainer(+filename)
      @pointer.free = FFI["mitie_free"]
    end

    def add(text, label)
      tokens = text.is_a?(Array) ? text : Mitie.tokenize(text)
      tokens_pointer = Utils.array_to_pointer(tokens)
      FFI.mitie_add_text_categorizer_labeled_text(@pointer, tokens_pointer, +label)
    end

    def beta
      FFI.mitie_text_categorizer_trainer_get_beta(@pointer)
    end

    def beta=(value)
      raise ArgumentError, "beta must be greater than or equal to zero" unless value >= 0

      FFI.mitie_text_categorizer_trainer_set_beta(@pointer, value)
    end

    def num_threads
      FFI.mitie_text_categorizer_trainer_get_num_threads(@pointer)
    end

    def num_threads=(value)
      FFI.mitie_text_categorizer_trainer_set_num_threads(@pointer, value)
    end

    def size
      FFI.mitie_text_categorizer_trainer_size(@pointer)
    end

    def train
      raise Error, "You can't call train() on an empty trainer" if size.zero?

      categorizer = FFI.mitie_train_text_categorizer(@pointer)

      raise Error, "Unable to create text categorizer. Probably ran out of RAM." if categorizer.null?

      Mitie::TextCategorizer.new(pointer: categorizer)
    end
  end
end
