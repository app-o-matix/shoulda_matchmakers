module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module FilterParam


          def filter_param_matcher_tests
            filter_params = Rails.application.config.filter_parameters
            if @app_controller_name == "ApplicationController" && filter_params.present?
              generate_filter_param_matcher_tests(filter_params)
            else
              []
            end
          end


          private

          def generate_filter_param_matcher_tests(filter_params)
            filter_param_tests = []
            multiple_params_tests_collections = []
            filter_params.each do |param|
              if param.is_a? Symbol
                filter_param_test = "  it { is_expected.to filter_param(:#{ param }) }"
                filter_param_tests = append_element(filter_param_test, filter_param_tests)
              else
                if param.to_s.include? "|"
                  # IMPLEMENTATION TODO: Determine if this is correct implementation for filtered parameters defined together, separated by boolean '|' operators.
                  params_array = param.to_s.sub("(?-mix:^((?-mix", "").gsub("|", ",:").gsub("::", ":").sub("))$)", "").split(',')
                  multiple_params_tests_collection = compose_multiple_params_tests_collection(params_array)
                  multiple_params_tests_collections = append_element(multiple_params_tests_collection, multiple_params_tests_collections)
                else
                  # IMPLEMENTATION TODO: Determine if this is correct implementation for filtered parameter regexes
                  param_regex = param.to_s.sub("(?-mix:", "/").sub("$)", "$/")
                  filter_param_test = "  it { is_expected.to filter_param(#{ param_regex }) }"
                  filter_param_tests = append_element(filter_param_test, filter_param_tests)
                end
              end
            end
            filter_param_tests = filter_param_tests + multiple_params_tests_collections
            format_tests(filter_param_tests)
          end

          def compose_multiple_params_tests_collection(params_array)
            multiple_params_tests_collection = compose_multiple_params_tests_collection_comment(params_array)
            params_array.each_with_index do |single_param, index|
              multiple_params_tests_collection.concat("  it { is_expected.to filter_param(#{ single_param }) }")
              if index < params_array.size - 1
                multiple_params_tests_collection.concat("\n")
              end
            end
           multiple_params_tests_collection
          end

          def compose_multiple_params_tests_collection_comment(params_array)
            collection_comment = "# IMPLEMENTATION TODO: Determine if this is proper implementation of filtered parameters defined together, separated by boolean operators.\n"
            collection_comment.concat("# The following filtered parameters are defined together in the app, separated by the '|' boolean operator:\n# ")
            params_array.each do |single_param|
              collection_comment.concat(single_param + ", ")
            end
            collection_comment.chomp!(", ").concat("\n")
          end

        end
      end
    end
  end
end
