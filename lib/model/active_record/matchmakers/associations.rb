module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module Associations


          def association_matcher_tests(association_type)
            association_type_instances = @app_class_name.constantize.reflect_on_all_associations(association_type.to_sym)
            if association_type_instances.present?
              generate_association_matcher_tests(association_type, association_type_instances)
            else
              []
            end
          end


          private

          def generate_association_matcher_tests(association_type, association_type_instances)
            association_tests = []
            association_type_instances = association_type_instances.map{ |ati| { association_class_name: ati.name, association_options: ati.options } }
            association_type_instances.each do |association_type_instance|
              association_test = generate_association_test_single_line(association_type, association_type_instance)
              if association_test.length > @working_generated_code_line_length
                association_test = generate_association_test_multiple_lines(association_type, association_type_instance)
              end
              association_tests = append_element(association_test, association_tests)
            end
            format_tests(association_tests)
          end

          def generate_association_test_single_line(association_type, association_type_instance)
            association_matcher = association_type.sub("belongs", "belong").sub("has", "have")
            association_test = "  it { is_expected.to #{ association_matcher }(:#{ association_type_instance[:association_class_name].to_s })"
            association_options_string = get_options_string(association_type_instance[:association_options])
            association_test.concat(association_options_string + " }")
          end

          def generate_association_test_multiple_lines(association_type, association_type_instance)
            association_matcher = association_type.sub("belongs", "belong").sub("has", "have")
            association_test = "  it do\n    is_expected.to #{ association_matcher }(:#{ association_type_instance[:association_class_name].to_s })"
            association_options_string = get_options_string(association_type_instance[:association_options])
            association_options_string = association_options_string.gsub(".", ".\n      ")
            association_test.concat(association_options_string + "\n  end")
          end

        end
      end
    end
  end
end
