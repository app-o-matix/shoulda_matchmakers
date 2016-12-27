module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module HaveReadonlyAttribute

          def have_readonly_attribute_matcher_tests
            readonly_attributes = @app_class_name.constantize.readonly_attributes
            if readonly_attributes.present?
              generate_have_readonly_attribute_matcher_tests(readonly_attributes)
            else
              []
            end
          end


          private

          def generate_have_readonly_attribute_matcher_tests(readonly_attributes)
            readonly_attribute_tests = []
            readonly_attributes.each do |attribute|
              readonly_attribute_test = "  it { is_expected.to have_readonly_attribute(:#{ attribute }) }"
              readonly_attribute_tests = append_element(readonly_attribute_test, readonly_attribute_tests)
            end
            format_tests(readonly_attribute_tests)
          end

        end
      end
    end
  end
end
