module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module Callbacks


          def use_action_matcher_tests(action_kind)
            use_actions = get_use_actions(@app_controller_name, action_kind)
            if use_actions.present?
              generate_use_action_matcher_tests(use_actions)
            else
              []
            end
          end


          private

          def generate_use_action_matcher_tests(use_actions)
            use_action_tests = []
            use_actions.each do |use_action|
              use_action_test = generate_use_action_test(use_action)
              use_action_tests = append_element(use_action_test, use_action_tests)
            end
            format_tests(use_action_tests)
          end

          def generate_use_action_test(use_action)
            if use_action[:filter] == "verify_authenticity_token" || use_action[:filter] == "verify_same_origin_request"
              use_action_test = "# IMPLEMENTATION TODO: Need to determine proper implementation of tests involving CSRF token\n"
              use_action_test.concat("  xit { is_expected.to use_#{ use_action[:kind] }_action(:#{ use_action[:filter] }) }")
            else
              use_action_test = "  it { is_expected.to use_#{ use_action[:kind] }_action(:#{ use_action[:filter] }) }"
            end
            use_action_test
          end

          def get_use_actions(app_controller_name, kind = nil)
            selected_actions_hashes = []
            all_actions = app_controller_name.constantize._process_action_callbacks
            if kind
              selected_actions = all_actions.select { |f| f.kind == kind }
              selected_actions = selected_actions.map(&:raw_filter).reject{ |action| action.class == Proc }
              selected_actions.each do |selected_action|
                selected_actions_hashes << { kind: kind.to_s, filter: selected_action.to_s }
              end
            end
            selected_actions_hashes
          end

        end
      end
    end
  end
end
