module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module Serialize


          def serialize_matcher_tests
            serialized_attributes = @app_class_name.constantize.serialized_attributes
            if serialized_attributes.present?
              generate_serialize_matcher_tests(serialized_attributes)
            else
              []
            end
          end


          private

          def generate_serialize_matcher_tests(serialized_attributes)
            serialize_tests = []
            serialized_attributes.map do |attribute, cast_type|
              object_class = cast_type.try(:object_class)
              if %w(Array Hash Object).include?(object_class.to_s) || (object_class == nil && cast_type.to_s.include?("JSON"))
                serialize_test = generate_serialize_test(attribute, object_class)
                serialize_tests = append_element(serialize_test, serialize_tests)
              else
                custom_serialize_test = generate_custom_serialize_test(attribute, cast_type, object_class)
                serialize_tests = append_element(custom_serialize_test, serialize_tests)
              end
            end
            format_tests(serialize_tests)
          end

          def generate_serialize_test(attribute, object_class)
            case object_class.to_s
            when "Array", "Hash"
              serialize_test = "  it { is_expected.to serialize(:#{ attribute }).as(#{ object_class }) }"
            when "Object"
              serialize_test = "  it { is_expected.to serialize(:#{ attribute }) }"
            else
              serialize_test = "  it { is_expected.to serialize(:#{ attribute }).as(JSON) }"
            end
            serialize_test
          end

          def generate_custom_serialize_test(attribute, cast_type, object_class)
            if object_class == nil
              custom_serializer_class = cast_type.to_s
              custom_serializer_class = custom_serializer_class.gsub(/#\</, "").gsub(/:.*\z/, "") if cast_type.to_s.include?("#<")
              custom_serialize_test = "  it { is_expected.to serialize(:#{ attribute }).as(#{ custom_serializer_class }) }"
            else
              custom_serializer_class = object_class.to_s
              custom_serializer_class = custom_serializer_class.gsub(/#\</, "").gsub(/:.*\z/, "") if object_class.to_s.include?("#<")
              custom_serialize_test = "  it { is_expected.to serialize(:#{ attribute }).as_instance_of(#{ custom_serializer_class }) }"
            end
            if custom_serialize_test.length > @working_generated_code_line_length
              custom_serialize_test = custom_serialize_test.sub("  it { ", "  it do\n    ").sub(").as", ").\n      as").sub("}) }", "})\n  end")
            end
            custom_serialize_test
          end

        end
      end
    end
  end
end
