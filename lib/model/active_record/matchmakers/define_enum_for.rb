module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module DefineEnumFor


          def define_enum_for_matcher_tests
            defined_enums = @app_class_name.constantize.defined_enums
            if defined_enums.present?
              generate_define_enum_for_matcher_tests(defined_enums)
            else
              []
            end
          end


          private

          def generate_define_enum_for_matcher_tests(defined_enums)
            define_enum_tests = []
            defined_enums.each do |attribute, enum_hash|
              define_enum_test = generate_enum_qualifier_examples(attribute, enum_hash)
              define_enum_test.concat("  it { is_expected.to define_enum_for(:#{ attribute }) }")
              define_enum_tests = append_element(define_enum_test, define_enum_tests)
            end
            format_tests(define_enum_tests)
          end

          def generate_enum_qualifier_examples(attribute, enum_hash)
            enum_names = get_enum_names(enum_hash)
            define_enum_test = "# You can use the 'with' qualifier to test that your enum has been defined with a certain set of known values.\n"
            if enum_names.join.length < 40
              define_enum_test.concat("# Example: 'it { is_expected.to define_enum_for(:#{ attribute }).with(#{ enum_names }) }'\n")
            else
              define_enum_test.concat("# Example: 'it { is_expected.to define_enum_for(:#{ attribute }).with([#{ enum_names[0] }, #{ enum_names[1] }, ...]) }'\n")
            end
            define_enum_test.concat("#\n# Source: https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/define_enum_for_matcher.rb\n#\n")
          end

          def get_enum_names(enum_hash)
            enum_names = []
            enum_hash.keys.each do |enum_name|
              enum_names = append_element(enum_name.to_sym, enum_names)
            end
            enum_names
          end

        end
      end
    end
  end
end
