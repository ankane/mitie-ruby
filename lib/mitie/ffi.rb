module Mitie
  module FFI
    extend Fiddle::Importer

    libs = Mitie.ffi_lib.dup
    begin
      dlload Fiddle.dlopen(libs.shift)
    rescue Fiddle::DLError => e
      retry if libs.any?
      raise e
    end

    extern "void mitie_free(void* object)"
    extern "char** mitie_tokenize(const char* text)"
    extern "char** mitie_tokenize_with_offsets(const char* text, unsigned long** token_offsets)"

    extern "mitie_named_entity_extractor* mitie_load_named_entity_extractor(const char* filename)"
    extern "unsigned long mitie_get_num_possible_ner_tags(const mitie_named_entity_extractor* ner)"
    extern "const char* mitie_get_named_entity_tagstr(const mitie_named_entity_extractor* ner, unsigned long idx)"

    extern "mitie_named_entity_detections* mitie_extract_entities(const mitie_named_entity_extractor* ner, char** tokens)"
    extern "unsigned long mitie_ner_get_num_detections(const mitie_named_entity_detections* dets)"
    extern "unsigned long mitie_ner_get_detection_position(const mitie_named_entity_detections* dets, unsigned long idx)"
    extern "unsigned long mitie_ner_get_detection_length(const mitie_named_entity_detections* dets, unsigned long idx)"
    extern "unsigned long mitie_ner_get_detection_tag(const mitie_named_entity_detections* dets, unsigned long idx)"
    extern "const char* mitie_ner_get_detection_tagstr(const mitie_named_entity_detections* dets, unsigned long idx)"
    extern "double mitie_ner_get_detection_score(const mitie_named_entity_detections* dets, unsigned long idx)"

    extern "mitie_ner_training_instance* mitie_create_ner_training_instance(char** tokens)"
    extern "unsigned long mitie_ner_training_instance_num_entities(const mitie_ner_training_instance* instance)"
    extern "unsigned long mitie_ner_training_instance_num_tokens(const mitie_ner_training_instance* instance)"
    extern "int mitie_overlaps_any_entity(mitie_ner_training_instance* instance, unsigned long start, unsigned long length)"
    extern "int mitie_add_ner_training_entity(mitie_ner_training_instance* instance, unsigned long start, unsigned long length, const char* label)"

    extern "mitie_binary_relation_detector* mitie_load_binary_relation_detector(const char* filename)"
    extern "const char* mitie_binary_relation_detector_name_string(const mitie_binary_relation_detector* detector)"
    extern "int mitie_entities_overlap(unsigned long arg1_start, unsigned long arg1_length, unsigned long arg2_start, unsigned long arg2_length)"
    extern "mitie_binary_relation* mitie_extract_binary_relation(const mitie_named_entity_extractor* ner, char** tokens, unsigned long arg1_start, unsigned long arg1_length, unsigned long arg2_start, unsigned long arg2_length)"
    extern "int mitie_classify_binary_relation(const mitie_binary_relation_detector* detector, const mitie_binary_relation* relation, double* score)"
  end
end
