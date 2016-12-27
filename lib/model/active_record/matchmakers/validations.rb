module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module Validations


          def validator_matcher_tests(validation_type)
            validators = extract_validators(@app_class_name, validation_type)
            if validators.present?
              generate_validation_matcher_tests(validators)
            else
              []
            end
          end


          private

          def generate_validation_matcher_tests(validators)
            validation_tests = []
            validators.map do |validator|
              if conditional_options_exist(validator.options)
                conditional_validation_tests = generate_conditional_validation_tests(validator)
                validation_tests = validation_tests + conditional_validation_tests
              else
                validation_test = generate_validation_test(validator, validator.options)
                validation_tests = append_element(validation_test, validation_tests)
              end
            end
            format_tests(validation_tests)
          end

          def generate_validation_test(validator, validator_options)
            validation_test = "  it { is_expected.to validate_#{ validator.kind.to_s }_of(:#{ validator.attributes.first.to_s })"
            if (validator.kind == :exclusion || validator.kind == :inclusion) && custom_exclusion_inclusion_test_required(validator_options)
              validation_test.sub!("  it {", "  xit {")
              custom_exclusion_inclusion_test_comment = get_custom_exclusion_inclusion_test_comment(validator_options)
              validation_test.prepend(custom_exclusion_inclusion_test_comment).concat(" }")
            else
              if validator.kind == :exclusion || validator.kind == :inclusion
                refined_validator_options = refine_exclusion_inclusion_non_conditional_option(validator_options)
              else
                refined_validator_options = validator_options
              end
              validator_options_string = get_options_string(refined_validator_options)
              validation_test.concat(validator_options_string + " }")
              if validation_test.length > @working_generated_code_line_length
                validation_test = generate_validation_test_multiple_lines(validator, validator_options_string)
              end
            end
            validation_test
          end

          def generate_validation_test_multiple_lines(validator, validator_options_string)
            validation_test = "  it do\n    is_expected.to validate_#{ validator.kind.to_s }_of(:#{ validator.attributes.first })"
            validator_options_string = validator_options_string.gsub(".", ".\n      ")
            validation_test.concat(validator_options_string).concat("\n  end")
          end

          def generate_conditional_validation_tests(validator)
            conditional_validation_tests = []
            validator_options = parse_validator_options(validator.options.dup)
            if (validator.kind == :exclusion || validator.kind == :inclusion) && validator_options[:non_conditional_options].present?
              validator_options[:non_conditional_options] = refine_exclusion_inclusion_non_conditional_option(validator_options[:non_conditional_options])
            end
            if all_option_values_are_symbols(validator_options[:if_option_values]) &&
                all_option_values_are_symbols(validator_options[:unless_option_values])
              conditional_validating_test = generate_conditional_validating_test(validator, validator_options)
              conditional_validation_tests = append_element(conditional_validating_test, conditional_validation_tests)
              conditional_non_validating_tests = generate_conditional_non_validating_tests(validator, validator_options)
              conditional_validation_tests = conditional_validation_tests + conditional_non_validating_tests
            # else
              # Skip tests due to non-symbol conditions (see below)
            end
            conditional_validation_tests
          end

          def generate_conditional_validating_test(validator, validator_options)
            conditional_validating_test = compose_conditional_validating_context_string(validator_options)
            validating_permutation = get_validating_true_false_permutation(validator_options)
            conditional_validating_test.concat(compose_conditional_before_strings(validator_options, validating_permutation))
            validating_test = generate_validation_test(validator, validator_options[:non_conditional_options])
            validating_test = adjust_conditional_test_indentation(validating_test)
            conditional_validating_test.concat(validating_test).concat("\n  end").prepend("# Conditional validating test\n#\n")
          end

          def generate_conditional_non_validating_tests(validator, validator_options)
            conditional_non_validating_tests = []
            possible_conditional_permutations = get_possible_true_false_permutations(validator_options)
            validating_permutation = get_validating_true_false_permutation(validator_options)
            non_validating_permutations = possible_conditional_permutations - [validating_permutation]
            non_validating_permutations.each do |non_validating_permutation|
              conditional_non_validating_test = generate_conditional_non_validating_test(validator, validator_options, non_validating_permutation)
              conditional_non_validating_tests << conditional_non_validating_test
            end
            if validator.options.key?(:unless)
              conditional_non_validating_tests[0] = conditional_non_validating_tests[0].prepend("# For more natural readability of 'is_expected.not_to' context lines, 'unless' is represented by 'if not'\n# and 'unless not' is represented by 'if'.\n#\n")
            end
            conditional_non_validating_tests[0] = conditional_non_validating_tests[0].prepend("# Conditional non-validating test(s)\n#\n")
            conditional_non_validating_tests
          end

          def generate_conditional_non_validating_test(validator, validator_options, non_validating_permutation)
            conditional_non_validating_test = compose_conditional_non_validating_context_string(validator_options, non_validating_permutation)
            conditional_non_validating_test.concat(compose_conditional_before_strings(validator_options, non_validating_permutation))
            non_validating_test = generate_validation_test(validator, validator_options[:non_conditional_options])
            non_validating_test.sub!("is_expected.to","is_expected.not_to")
            non_validating_test = adjust_conditional_test_indentation(non_validating_test)
            conditional_non_validating_test.concat(non_validating_test)
            conditional_non_validating_test.concat("\n  end")
          end

          def custom_exclusion_inclusion_test_required(exclusion_inclusion_option)
            exclusion_inclusion_enumerable = exclusion_inclusion_option[:in] || exclusion_inclusion_option[:within]
            if exclusion_inclusion_enumerable.is_a?(Array) || exclusion_inclusion_enumerable.is_a?(Range)
              false
            else
              true
            end
          end

          def get_custom_exclusion_inclusion_test_comment(exclusion_inclusion_option)
            exclusion_inclusion_enumerable = exclusion_inclusion_option[:in] || exclusion_inclusion_option[:within]
            # CONFIRMATION TODO: Confirm whether or not enumerable could be a 'Proc' that isn't a 'lambda'
            custom_exclusion_inclusion_test_comment = if exclusion_inclusion_enumerable.lambda?
                                                        "# Note: Your 'in:/within:' configuration option value is a 'Lambda'." +
                                                        " You will need to implement a customized test.\n"
                                                      elsif exclusion_inclusion_enumerable.respond_to?(:call)
                                                        "# Note: Your 'in:/within:' configuration option value is a 'Proc'." +
                                                        " You will need to implement a customized test.\n"
                                                      else
                                                        "# Alert: Invalid 'in:/within:' enumerable object type: '#{ exclusion_enumerable.class.name.to_s }'\n" +
                                                        "#        Valid exclusion 'in:/within:' enumerable object types: 'Array', 'Range'" +
                                                        " (or a proc, lambda or symbol which returns an enumerable)\n"
                                                      end
            custom_exclusion_inclusion_test_comment.concat("# Remove the 'x' from 'xit' once test customization has been implemented.\n")
          end

          def refine_exclusion_inclusion_non_conditional_option(exclusion_inclusion_option)
            refined_exclusion_inclusion_option = {}
            exclusion_inclusion_enumerable = exclusion_inclusion_option[:in] || exclusion_inclusion_option[:within]
            if exclusion_inclusion_enumerable.is_a?(Array)
              refined_exclusion_inclusion_option = { in_array: exclusion_inclusion_enumerable }
            elsif exclusion_inclusion_enumerable.is_a?(Range)
              refined_exclusion_inclusion_option = { in_range: exclusion_inclusion_enumerable }
            end
            refined_exclusion_inclusion_option
          end

        end
      end
    end
  end
end
