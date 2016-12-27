module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module AcceptNestedAttributesFor


          def accept_nested_attributes_for_matcher_tests
            nested_attributes_options = @app_class_name.constantize.nested_attributes_options
            if nested_attributes_options.present?
              generate_accept_nested_attributes_for_matcher_tests(nested_attributes_options)
            else
              []
            end
           end


          private

          def generate_accept_nested_attributes_for_matcher_tests(nested_attributes_options)
            nested_attributes_tests = []
            nested_attributes_options.map do |class_name, options|
              nested_attributes_class_name = class_name.to_s
              nested_attributes_options = trim_options(options)
              nested_attributes_test = generate_nested_attributes_test(nested_attributes_class_name, nested_attributes_options)
              nested_attributes_tests = append_element(nested_attributes_test, nested_attributes_tests)
            end
            format_tests(nested_attributes_tests)
          end

          def generate_nested_attributes_test(nested_attributes_class_name, nested_attributes_options)
            nested_attributes_test = generate_nested_attributes_test_single_line(nested_attributes_class_name, nested_attributes_options)
            if nested_attributes_test.length > @working_generated_code_line_length
              nested_attributes_test = generate_nested_attributes_test_multiple_lines(nested_attributes_class_name, nested_attributes_options)
            end
            nested_attributes_test
          end

          def generate_nested_attributes_test_single_line(nested_attributes_class_name, nested_attributes_options)
            nested_attributes_test = "  it { is_expected.to accept_nested_attributes_for(:#{ nested_attributes_class_name })"
            nested_attributes_options_string = get_options_string(nested_attributes_options)
            nested_attributes_test.concat(nested_attributes_options_string + " }")
            nested_attributes_test
          end

          def generate_nested_attributes_test_multiple_lines(nested_attributes_class_name, nested_attributes_options)
            nested_attributes_test = "  it do\n    is_expected.to accept_nested_attributes_for(:#{ nested_attributes_class_name })"
            nested_attributes_options_string = get_options_string(nested_attributes_options)
            nested_attributes_options_string = nested_attributes_options_string.gsub(".", ".\n      ")
            nested_attributes_test.concat(nested_attributes_options_string + "\n  end")
            nested_attributes_test
          end

          def trim_options(options)
            options_untrimmed = options.dup
            options_trimmed = {}
            options_untrimmed.delete(:allow_destroy) if options[:allow_destroy].to_s == "false"
            options_untrimmed.delete(:update_only)   if options[:update_only].to_s   == "false"
            options_trimmed.merge(options_untrimmed)
          end

        end
      end
    end
  end
end
