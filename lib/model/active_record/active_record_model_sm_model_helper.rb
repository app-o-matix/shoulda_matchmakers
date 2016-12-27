require 'model/active_record/options_definition'

module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module ActiveRecordModelSmModelHelper


        def compose_extended_model_file_path(app_class_name)
          Rails.root.join("app", "models").to_s + "/" + app_class_name.underscore.concat(".rb")
        end

        def extract_validators(app_class_name, validator_type)
          extracted_validators = app_class_name.constantize.validators.select do |validator|
                                   validator.class.to_s == validator_type.to_s
                                 end
          extracted_validators.flatten
        end

        def conditional_options_exist(validator_options)
          if validator_options.key?(:if) || validator_options.key?(:unless)
            true
          else
            false
          end
        end

        def parse_validator_options(validator_options)
          non_conditional_options = validator_options
          if validator_options.key?(:if)
            if_option_values = non_conditional_options.delete(:if)
            if_option_values = [if_option_values] if !if_option_values.is_a?(Array)
          else
            if_option_values = []
          end
          if validator_options.key?(:unless)
            unless_option_values = non_conditional_options.delete(:unless)
            unless_option_values = [unless_option_values] if !unless_option_values.is_a?(Array)
          else
            unless_option_values = []
          end
          { non_conditional_options: non_conditional_options, if_option_values: if_option_values, unless_option_values: unless_option_values }
        end

        def order_options(options)
          options_unordered = options.dup
          options_ordered = {}
          options_ordered = options_ordered.merge({ :in=>options_unordered.delete(:in) }) if options_unordered.include?(:in)
          options_ordered = options_ordered.merge({ :minimum=>options_unordered.delete(:minimum) }) if options_unordered.include?(:minimum)
          options_ordered = options_ordered.merge({ :maximum=>options_unordered.delete(:maximum) }) if options_unordered.include?(:maximum)
          options_ordered.merge(options_unordered)
        end

        def all_option_values_are_symbols(option_values)
          option_values_are_symbols = true
          if option_values.present?
            option_values.each do |option_value|
              if !option_value.is_a?(Symbol)
                option_values_are_symbols = false
              end
            end
          end
          option_values_are_symbols
        end

        def get_possible_true_false_permutations(validator_options)
          number_of_conditional_option_values = validator_options[:if_option_values].size +
                                                  validator_options[:unless_option_values].size
          [true, false].repeated_permutation(number_of_conditional_option_values).to_a
        end

        def get_validating_true_false_permutation(validator_options)
          validating_permutation = []
          validator_options[:if_option_values].size.times do |n|
            validating_permutation << true
          end
          validator_options[:unless_option_values].size.times do |n|
            validating_permutation << false
          end
          validating_permutation
        end

        def get_options_string(options)
          options_hash = ::ShouldaMatchmakers::Model::ActiveRecord::OptionsDefinition.new.options_hash
          options_string = ""
          options.map do |option_key, option_value|
           if options_hash.key?(option_key)
              option_string = options_hash[option_key].to_s
              option_value_refined = apply_option_value_qualifiers(option_value, option_string)
              option_string = option_string.gsub(/\s*\{\s*/,"").gsub(/\s*\}\s*/,"").gsub(/option_value(?:\.[a-zA-Z0-9_]+)*/, option_value_refined)
              options_string.concat("." + option_string)
            end
          end
          options_string
        end

        def apply_option_value_qualifiers(option_value, association_option_string)
          option_value_refined = option_value
          option_value_qualifiers = association_option_string.scan(/(?: option_value|\.[a-zA-Z0-9_]+)(\.[a-zA-Z0-9_]+)/)
          option_value_qualifiers.each do |option_value_qualifier|
            case option_value_qualifier
              when ".first"
                option_value_refined = option_value_refined.first
              when ".last"
                option_value_refined = option_value_refined.last
              when ".to_s"
                option_value_refined = option_value_refined.to_s
            end
          end
          option_value_refined.to_s
        end

        def compose_conditional_validating_context_string(validator_options)
          validating_context_string = "  context \""
          conditional_option_values = validator_options[:if_option_values] + validator_options[:unless_option_values]
          conditional_option_values.each_with_index do |option_value, cov_index|
            if cov_index < validator_options[:if_option_values].size
              validating_context_string.concat("if #{ option_value.to_s.chomp('?')} and ")
            else
              validating_context_string.concat("unless #{ option_value.to_s.chomp('?')} and ")
            end
          end
          validating_context_string.chomp!(" and ").concat("\" do\n")
        end

        def compose_conditional_non_validating_context_string(validator_options, non_validating_permutation)
          non_validating_context_string = "  context \""
          conditional_option_values = validator_options[:if_option_values] + validator_options[:unless_option_values]
          conditional_option_values.each_with_index do |conditional_option_value, cov_index|
            if cov_index < validator_options[:if_option_values].size
              non_validating_context_string.concat(get_if_context_condition(conditional_option_value, non_validating_permutation[cov_index]))
            else
              non_validating_context_string.concat(get_unless_context_condition(conditional_option_value, non_validating_permutation[cov_index]))
            end
          end
          non_validating_context_string.chomp!(" and ").concat("\" do\n")
        end

        def get_if_context_condition(option_value, permutation_boolean_value_for_option)
          if permutation_boolean_value_for_option
            if_context_condition = "if #{ option_value.to_s.chomp('?')} and "
          else
            if_context_condition = "if not #{ option_value.to_s.chomp('?')} and "
          end
          if_context_condition
        end

        def get_unless_context_condition(option_value, permutation_boolean_value_for_option)
          if permutation_boolean_value_for_option
            unless_context_condition = "if (unless not) #{ option_value.to_s.chomp('?')} and "
          else
            unless_context_condition = "if not (unless) #{ option_value.to_s.chomp('?')} and "
          end
          unless_context_condition
        end

        def compose_conditional_before_strings(validator_options, conditional_options_permutation)
          conditional_before_strings = ""
          conditional_option_values = validator_options[:if_option_values] + validator_options[:unless_option_values]
          conditional_option_values.each_with_index do |conditional_option_value, cov_index|
            conditional_before_strings.concat("    before { allow(subject).to receive(:#{ conditional_option_value }).and_return(#{ conditional_options_permutation[cov_index] }) }\n")
          end
          conditional_before_strings
        end

        def append_element(element, element_set)
          if element.present?
            element_set << element
          end
          element_set
        end

        def adjust_conditional_test_indentation(conditional_test)
          if conditional_test.include?("\n")
            conditional_test.sub("  it do\n","\n    it do\n").
                             sub("it do\n    ","it do\n      ").
                             gsub(").\n    ",").\n      ").
                             sub("\n  end","\n    end")
          else
            conditional_test.sub("  it {", "\n    it {")
          end
        end

        def format_tests(tests)
          formatted_tests = properly_line_space_tests(tests)
          formatted_tests.flatten.compact.uniq.join("\n")
        end

        def properly_line_space_tests(tests)
          tests_properly_line_spaced = []
          previous_test = ""
          tests.each do |test|
            if (test.include?("\n") && previous_test.present?) ||
                 (!test.include?("\n") && previous_test.include?("\n"))
              test = "\n" + test
            end
            tests_properly_line_spaced << test
            previous_test = test
          end
          tests_properly_line_spaced
        end

      end
    end
  end
end
