module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module AllowValue


          def allow_value_matcher_tests
            allow_value_validators = extract_validators(@app_class_name, ::ActiveModel::Validations::FormatValidator)
            if allow_value_validators.present?
              generate_allow_value_matcher_tests(allow_value_validators)
            else
              []
            end
          end


          private

          def generate_allow_value_matcher_tests(validators)
            allow_value_tests = []
            validators.map do |validator|
              if conditional_options_exist(validator.options)
                allow_value_tests = allow_value_tests + generate_conditional_allow_value_tests(validator)
              else
                allow_value_test = generate_allow_value_test(validator, validator.options)
                allow_value_tests = append_element(allow_value_test, allow_value_tests)
                allow_value_expected_not_to_test = generate_allow_value_expected_not_to_test(allow_value_test)
                allow_value_tests = append_element(allow_value_expected_not_to_test, allow_value_tests)
              end
            end
            format_tests(allow_value_tests)
          end

          def generate_allow_value_test(validator, validator_options)
            allow_value_test = "  xit { is_expected.to allow_values('','').for(:#{ validator.attributes.first })"
            allow_value_options_string = get_options_string(validator_options)
            allow_value_test.concat(allow_value_options_string + " }")
            if allow_value_test.length > @working_generated_code_line_length
              allow_value_test = generate_allow_value_test_multiple_lines(validator, allow_value_options_string)
            end
            allow_value_test_comment = get_allow_value_test_comment(validator)
            allow_value_test.prepend(allow_value_test_comment)
          end

          def generate_allow_value_test_multiple_lines(validator, allow_value_options_string)
            allow_value_test = "  xit do\n    is_expected.to allow_values('','').\n      for(:#{ validator.attributes.first })"
            allow_value_options_string = allow_value_options_string.gsub(".", ".\n      ")
            allow_value_test.concat(allow_value_options_string).concat("\n  end")
          end

          def generate_allow_value_expected_not_to_test(allow_value_test)
            if allow_value_test.include?("DO NOT MATCH")
              allow_value_test.sub("DO NOT MATCH", "MATCH").gsub("is_expected.to", "is_expected.not_to")
            else
              allow_value_test.sub("MATCH", "DO NOT MATCH").gsub("is_expected.to", "is_expected.not_to")
            end
          end

          def generate_conditional_allow_value_tests(validator)
            conditional_allow_value_tests = []
            allow_value_options = parse_validator_options(validator.options.dup)
            if all_option_values_are_symbols(allow_value_options[:if_option_values]) &&
                all_option_values_are_symbols(allow_value_options[:unless_option_values])
              conditional_allow_value_validating_test = generate_conditional_allow_value_validating_test(validator, allow_value_options)
              conditional_allow_value_tests = append_element(conditional_allow_value_validating_test, conditional_allow_value_tests)
              conditional_allow_value_non_validating_tests = generate_conditional_allow_value_non_validating_tests(validator, allow_value_options)
              conditional_allow_value_tests = conditional_allow_value_tests + conditional_allow_value_non_validating_tests
            # else
              # Skip tests due to non-symbol conditions (see below)
            end
            conditional_allow_value_tests
          end

          def generate_conditional_allow_value_validating_test(validator, allow_value_options)
            conditional_validating_test = compose_conditional_validating_context_string(allow_value_options)
            validating_permutation = get_validating_true_false_permutation(allow_value_options)
            conditional_validating_test.concat(compose_conditional_before_strings(allow_value_options, validating_permutation))
            validating_test = generate_allow_value_test(validator, allow_value_options[:non_conditional_options])
            validating_test = adjust_conditional_test_indentation(validating_test)
            conditional_validating_test.concat(validating_test).concat("\n  end").prepend("# Conditional validating test\n#\n")
          end

          def generate_conditional_allow_value_non_validating_tests(validator, allow_value_options)
            conditional_non_validating_tests = []
            possible_conditional_permutations = get_possible_true_false_permutations(allow_value_options)
            validating_permutation = get_validating_true_false_permutation(allow_value_options)
            non_validating_permutations = possible_conditional_permutations - [validating_permutation]
            non_validating_permutations.each do |non_validating_permutation|
              conditional_non_validating_test = generate_conditional_allow_value_non_validating_test(validator, allow_value_options, non_validating_permutation)
              conditional_non_validating_tests = append_element(conditional_non_validating_test, conditional_non_validating_tests)
            end
            if validator.options.key?(:unless)
              conditional_non_validating_tests[0] = conditional_non_validating_tests[0].prepend("# For more natural readability of 'is_expected.not_to' context lines, 'unless' is represented by 'if not'\n# and 'unless not' is represented by 'if'.\n#\n")
            end
            conditional_non_validating_tests[0] = conditional_non_validating_tests[0].prepend("# Conditional non-validating test(s)\n#\n")
            conditional_non_validating_tests
          end

          def generate_conditional_allow_value_non_validating_test(validator, allow_value_options, non_validating_permutation)
            conditional_non_validating_test = compose_conditional_non_validating_context_string(allow_value_options, non_validating_permutation)
            conditional_non_validating_test.concat(compose_conditional_before_strings(allow_value_options, non_validating_permutation))
            non_validating_test = generate_allow_value_test(validator, allow_value_options[:non_conditional_options])
            non_validating_test.sub!("is_expected.to","is_expected.not_to")
            non_validating_test = adjust_conditional_test_indentation(non_validating_test)
            conditional_non_validating_test.concat(non_validating_test)
            conditional_non_validating_test.concat("\n  end")
          end

          def get_allow_value_test_comment(validator)
            allow_value_test_comment = ""
            if validator.options.key? :with
              expected_to_match_value_format = get_value_format(validator.options[:with].source.to_s)
              allow_value_test_comment = "#\n# Enter values that MATCH this format: #{ expected_to_match_value_format }\n"
            elsif validator.options.key? :without
              expected_to_match_value_format = get_value_format(validator.options[:without].source.to_s)
              allow_value_test_comment = "#\n# Enter values that DO NOT MATCH this format: #{ expected_to_match_value_format }\n"
            end
            allow_value_test_comment
          end

          def get_value_format(format)
            # IMPLEMENTATION TODO: Add additional predefined Rails regexp's, if they exist
            uri_regexp_string = URI.regexp.to_s.gsub(/^\(\?x-mi:/,"").gsub('\/', '/').chomp(")")
            case format
              when uri_regexp_string
                "URI.regexp"
              else
                format
            end
          end

        end
      end
    end
  end
end
