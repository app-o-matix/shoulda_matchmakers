require 'controller/action_controller/permitted_params_definition'

module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module Permit


          def permit_matcher_tests
            app_controller_permitted_params_defs = get_app_controller_permitted_params_defs(@app_controller_name)
            if app_controller_permitted_params_defs.present?
              app_controller_permitted_params_defs_and_calls =
                add_app_controller_permitted_params_calls_to_defs(app_controller_permitted_params_defs)
              permit_matcher_tests = generate_permit_matcher_tests(app_controller_permitted_params_defs_and_calls)
              permit_matcher_tests
            else
              []
            end
          end


          private

          def get_app_controller_permitted_params_defs(app_controller_name)
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              app_controller_permitted_params_defs = parse_app_controller_for_permitted_params_defs(app_controller_name, app_controller_file_path)
              app_controller_permitted_params_defs
            else
              []
            end
          end

          def parse_app_controller_for_permitted_params_defs(app_controller_name, app_controller_file_path)
            current_app_controller_method = ""
            parsing_params = false
            app_controller_permitted_params_def = nil
            app_controller_permitted_params_defs = []
            continued_from_previous_line = false
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                simplified_params_line = app_controller_file_line
                if continued_from_previous_line
                  app_controller_permitted_params_def.permitted_params_string.concat(app_controller_file_line)
                  if app_controller_permitted_params_def.params_array_type == "space_delimited_array_of_symbols" ||
                      (app_controller_permitted_params_def.params_array_type == "" && app_controller_file_line.include?("%i"))
                    app_controller_permitted_params_def.params_array_type = "space_delimited_array_of_symbols" if app_controller_permitted_params_def.params_array_type == ""
                    app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, app_controller_file_line)
                  elsif app_controller_permitted_params_def.params_array_type == "comma_delimited_array_of_symbols" ||
                      (app_controller_permitted_params_def.params_array_type == "" && app_controller_file_line =~ /^\s+(?::[a-z_][a-z0-9_]*(?:\s*|\s*,?\s*))+(?:\)|\n)/)
                    app_controller_permitted_params_def.params_array_type = "comma_delimited_array_of_symbols" if app_controller_permitted_params_def.params_array_type == ""
                    app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, app_controller_file_line)
                  elsif app_controller_permitted_params_def.params_array_type == "other" ||
                      (app_controller_permitted_params_def.params_array_type == "" && app_controller_file_line =~ /^\s+[a-zA-Z:_\[]/)
                    app_controller_permitted_params_def.params_array_type = "other" if app_controller_permitted_params_def.params_array_type == ""
                    app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, app_controller_file_line)
                  end
                  # IMPLEMENTATION TODO: Determine if possible to handle more complex params list containing nested parens
                  if app_controller_file_line.include?("(") && !(app_controller_file_line.include?("%i") || app_controller_permitted_params_def.params_array_type == "space_delimited_array_of_symbols")
                    app_controller_permitted_params_def = nil
                    parsing_params = false
                    continued_from_previous_line = false
                  elsif app_controller_file_line.include?(")")
                    app_controller_permitted_params_def.permitted_params.flatten!
                    app_controller_permitted_params_def.permitted_params.uniq!
                    if app_controller_permitted_params_def.params_array_type == "comma_delimited_array_of_symbols"
                      app_controller_permitted_params_def.permitted_params = app_controller_permitted_params_def.permitted_params.each{ |permitted_param| permitted_param.sub!(":", "") }
                    end
                    app_controller_permitted_params_defs = append_element(app_controller_permitted_params_def, app_controller_permitted_params_defs)
                    app_controller_permitted_params_def = nil
                    parsing_params = false
                    continued_from_previous_line = false
                  end
                elsif app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = update_current_app_controller_method(app_controller_file_line)
                else
                  if app_controller_file_line =~ /params\.require\(\s*:/ && current_app_controller_method.present?
                    app_controller_permitted_params_def = create_app_controller_permitted_params_def(app_controller_name, current_app_controller_method, app_controller_file_line)
                    simplified_params_line = remove_params_require_from_line(simplified_params_line)
                  end
                  if app_controller_file_line =~ /permit\(/ && app_controller_permitted_params_def.present? && app_controller_permitted_params_def.params_class.present?
                    if !app_controller_permitted_params_def.permitted_params_string.include?("permit(")
                      app_controller_permitted_params_def.permitted_params_string.concat(app_controller_file_line)
                    end
                    simplified_params_line = remove_permit_from_line(simplified_params_line)
                    if simplified_params_line.include?("(") && !simplified_params_line.include?("%i")
                      app_controller_permitted_params_def = nil
                    else
                      parsing_params = true
                    end
                  end
                  if parsing_params
                    if app_controller_file_line =~ /permit\(\s*%i/
                      app_controller_permitted_params_def.params_array_type = "space_delimited_array_of_symbols"
                      app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, simplified_params_line)
                    elsif app_controller_file_line =~ /permit\(\s*:[a-z_]/
                      app_controller_permitted_params_def.params_array_type = "comma_delimited_array_of_symbols"
                      app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, simplified_params_line)
                    elsif app_controller_file_line =~ /permit\(\s*(?:::|[a-zA-Z\[])/
                      app_controller_permitted_params_def.params_array_type = "other"
                      app_controller_permitted_params_def = update_permitted_params_def(app_controller_permitted_params_def, simplified_params_line)
                    end
                    if simplified_params_line.include?(")")
                      app_controller_permitted_params_def.permitted_params.flatten!
                      app_controller_permitted_params_def.permitted_params.uniq!
                      if app_controller_permitted_params_def.params_array_type == "comma_delimited_array_of_symbols"
                        app_controller_permitted_params_def.permitted_params = app_controller_permitted_params_def.permitted_params.each{ |permitted_param| permitted_param.sub!(":", "") }
                      end
                      app_controller_permitted_params_defs = append_element(app_controller_permitted_params_def, app_controller_permitted_params_defs)
                      app_controller_permitted_params_def = nil
                      parsing_params = false
                    else
                      continued_from_previous_line = true
                    end
                  end
                end
              end
            end
            app_controller_permitted_params_defs
          end

          def update_permitted_params_def(permitted_params_def, file_line)
            case permitted_params_def.params_array_type
              when "comma_delimited_array_of_symbols"
                update_permitted_params_def_comma_delimited_array_of_symbols_type(permitted_params_def, file_line)
              when "space_delimited_array_of_symbols"
                update_permitted_params_def_space_delimited_array_of_symbols_type(permitted_params_def, file_line)
              when "other"
                update_permitted_params_def_other_type(permitted_params_def)
              else
                permitted_params_def
            end
          end

          def update_permitted_params_def_comma_delimited_array_of_symbols_type(permitted_params_def, file_line)
            updated_permitted_params_def = permitted_params_def.dup
            permitted_params_contained_in_line = file_line.scan(/((?::[a-z_][a-z0-9_]*\s*,?\s*)+)(?:\)|\n)/)
            if permitted_params_contained_in_line.present?
              permitted_params_string = permitted_params_contained_in_line.flatten.first
              permitted_params = permitted_params_string.gsub(" ", "").split(",")
              if permitted_params.select{ |permitted_param| permitted_param.first != ":"}.count > 0
                updated_permitted_params_def.params_array_type = "other"
                updated_permitted_params_def.permitted_params = []
              else
                permitted_params.uniq!
                updated_permitted_params_def.permitted_params = updated_permitted_params_def.permitted_params + permitted_params
              end
            end
            updated_permitted_params_def
          end

          def update_permitted_params_def_other_type(permitted_params_def)
            updated_permitted_params_def = permitted_params_def.dup
            updated_permitted_params_def.permitted_params = []
            updated_permitted_params_def
          end

          def update_permitted_params_def_space_delimited_array_of_symbols_type(permitted_params_def, file_line)
            updated_permitted_params_def = permitted_params_def.dup
            permitted_params_contained_in_line = file_line.scan(/(?!:[a-z0-9_]+)(?:\s|\)|\n)((?:[a-z][a-z0-9_]*\s*)+)(?:\)|\n)/)
            if permitted_params_contained_in_line.present?
              permitted_params_string = permitted_params_contained_in_line.flatten.first
              permitted_params = permitted_params_string.gsub(/\n/," ").gsub(/\s+/, " ").split(" ")
              if permitted_params.select{ |permitted_param| permitted_param.first[/[^a-z_]/] == permitted_param.first }.count > 0
                updated_permitted_params_def.params_array_type = "other"
                updated_permitted_params_def.permitted_params = []
              else
                permitted_params.uniq!
                updated_permitted_params_def.permitted_params = updated_permitted_params_def.permitted_params + permitted_params
              end
            end
            updated_permitted_params_def
          end

          def remove_params_require_from_line(file_line)
            file_line.sub(/params\.require\(\s*:[a-z][a-z0-9_]*\s*\)/, "")
          end

          def remove_permit_from_line(file_line)
            file_line.sub(/\.permit\(/, "")
          end

          def create_app_controller_permitted_params_def(defining_controller, defining_method, app_controller_file_line)
            params_class = app_controller_file_line.scan(/params\.require\(\s*(:[a-z][a-z0-9_]*)\s*\)/).flatten.first
            ::ShouldaMatchmakers::Controller::ActionController::PermittedParamsDefinition.new(defining_controller, defining_method, params_class)
          end

          def add_app_controller_permitted_params_calls_to_defs(app_controller_permitted_params_defs)
            permitted_params_defs = app_controller_permitted_params_defs.dup
            permitted_params_defs.each do |permitted_params_def|
              @app_action_controller_descendants_names.each do |app_action_controller_controller_name|
                app_controller_file_path = compose_extended_app_controller_file_path(app_action_controller_controller_name)
                if File.exists?(app_controller_file_path)
                  File.open(app_controller_file_path, 'r') do |app_controller_file|
                    current_app_controller_method = nil
                    app_controller_file.each_line do |app_controller_file_line|
                      if app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                        current_app_controller_method = update_current_app_controller_method(app_controller_file_line)
                      else
                        if app_controller_file_line =~ /\(\s*[a-zA-Z0-9_:\s,@]*#{ permitted_params_def.defining_method }/
                          permitted_params_def.calls <<
                              get_permitted_params_call_hash(permitted_params_def.defining_method, app_action_controller_controller_name, current_app_controller_method, app_controller_file_line)
                        end
                      end
                    end
                  end
                end
              end
              if permitted_params_def.calls == []
                call_hash = { calling_controller: "unidentified_calling_controller", calling_method: "unidentified_calling_method",
                              calling_class: "unidentified_calling_class", calling_class_method: "unidentified_calling_class_method",
                              call_implementation: "missing" }
                permitted_params_def.calls << call_hash
              end
            end
            permitted_params_defs
          end

          def get_permitted_params_call_hash(defining_method, calling_controller_name, calling_method, file_line)
            if file_line =~ /(?:::)?[A-Z][a-zA-Z0-9:]*\.[a-z]+[a-z0-9_]*\(\s*#{ defining_method }\s*\)/
              calling_class, calling_class_method = file_line.match(/((?:::)?[A-Z][a-zA-Z0-9:]*)\.([a-z]+[a-z0-9_]*)\(\s*#{ defining_method }\s*\)/).captures
              { calling_controller: calling_controller_name, calling_method: calling_method,
                calling_class: calling_class, calling_class_method: calling_class_method,
                call_implementation: "simple" }
            elsif file_line =~ /[a-zA-Z0-9:@_]+\.[a-z]+[a-z0-9_]*\([a-zA-Z0-9_:\s,@]*#{ defining_method }/
              calling_class, calling_class_method = file_line.match(/([a-zA-Z0-9:@_]+)\.([a-z]+[a-z0-9_]*)\([a-zA-Z0-9_:\s,@]*#{ defining_method }/).captures
              { calling_controller: calling_controller_name, calling_method: calling_method,
                calling_class: calling_class, calling_class_method: calling_class_method,
                call_implementation: "complex" }
            else
              { calling_controller: calling_controller_name, calling_method: calling_method,
                calling_class: "unidentified_calling_class", calling_class_method: "unidentified_calling_class_method",
                call_implementation: "complex" }
            end
          end

          def generate_permit_matcher_tests(permitted_params_defs)
            permit_tests = []
            permitted_params_defs.each do |permitted_params_def|
              permitted_params_def.calls.each do |call|
                if call[:call_implementation] == "missing"
                  permit_test = "# Unable to locate params definition call. Locate params definition call to identify missing values\n"
                  permit_test.concat("# (see :unidentified_calling_class and :unidentified_calling_class_method below).\n")
                  permit_test.concat("# Remove 'x' from 'xit' once these missing values and any additional required values have been provided.\n")
                  permit_test.concat("  xit do\n")
                elsif call[:call_implementation] == "complex"
                  if call[:calling_class] == "unidentified_calling_class" || call[:calling_class_method] == "unidentified_calling_class_method"
                    permit_test = "# Unable to identify params definition calling class and/or calling class method. Examine params definition call\n"
                    permit_test.concat("# in the '#{ call[:calling_method] }' method of '#{ call[:calling_controller] }' to identify these missing values.\n")
                    permit_test.concat("# Remove 'x' from 'xit' once these missing values and any additional required values have been provided.\n")
                    permit_test.concat("  xit do\n")
                  else
                    permit_test = "# Params definition call contains complexities that make it difficult for ShouldaMatchmakers to parse completely.\n"
                    permit_test.concat("# Examine params definition call in the '#{ call[:calling_method] }' method of '#{ call[:calling_controller] }' to identify any additional required values.\n")
                    permit_test.concat("# Remove 'x' from 'xit' once all required values have been provided.\n")
                    permit_test.concat("  xit do\n")
                  end
                else
                  permit_test = "  it do\n"
                end
                permit_test.concat(compose_permit_test_params_portion(permitted_params_def))
                permit_test.concat(compose_permit_test_expectation_portion(permitted_params_def))
                permit_test.concat(compose_permit_test_for_portion(call[:calling_class_method]))
                permit_test.concat(compose_permit_test_on_portion(call[:calling_class]))
                permit_tests << permit_test
              end
            end
            format_tests(permit_tests)
          end

          def compose_permit_test_params_portion(permitted_params_def)
            permit_test_params_portion = "    params = {\n      #{ permitted_params_def.params_class.to_s[1..-1] }: {\n"
            if permitted_params_def.params_array_type == "other"
              permit_test_params_portion.concat("        # Complex params definition. See comment above.")
            else
              permitted_params_def.permitted_params.each do |permitted_param|
                permit_test_params_portion.concat("        #{ permitted_param.to_s }: '',\n")
              end
              permit_test_params_portion.chomp!(",\n")
            end
            permit_test_params_portion.concat("\n      }\n    }\n")
          end

          def compose_permit_test_expectation_portion(permitted_params_def)
            permit_test_expectation_portion = "    is_expected.to permit(\n"
            if permitted_params_def.params_array_type == "other"
              permit_test_expectation_portion.concat("        # Complex params definition. See comment above.")
            else
              permitted_params_def.permitted_params.each do |permitted_param|
                permit_test_expectation_portion.concat("      :#{ permitted_param },\n")
              end
              permit_test_expectation_portion.chomp!(",\n")
            end
            permit_test_expectation_portion.concat("\n    ).\n")
          end

          def compose_permit_test_for_portion(calling_class_method)
            if calling_class_method.present?
              "      for(:#{ calling_class_method }, params: params).\n"
            else
              "      for(:unidentified_calling_class_method, params: params).\n"
            end
          end

          def compose_permit_test_on_portion(calling_class)
            if calling_class.present?
              if calling_class.underscore.include?("/")
                # IMPLEMENTATION TODO: Determine if this is the proper implementation of calling class (colon/quotes) when it is a path (i.e. namespaced).
                "      on(:'#{ calling_class.underscore }')\n  end"
              else
                "      on(:#{ calling_class.underscore })\n  end"
              end
            else
              "      on(unidentified_calling_class)\n  end"
            end
          end

          def update_current_app_controller_method(line)
            line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
          end

        end
      end
    end
  end
end


# IMPLEMENTATION TODO: Determine if the variables used in this matcher generator represent the appropriate values, as shown here:
#
# it do
#   params = {
#     <params_class>: {
#       <permitted_params_def.permitted_params.each>: <sample_value>
#     }
#   }
#   should permit(:<permitted_params_def.permitted_params.each>).
#     for(:<calling_class_method>, params: params).
#     on(:<calling_class>)
# end
#

# TODO: Nested Attributes
# def protected_branch_params
#   params.require(:protected_branch).permit(:name,
#                                            merge_access_levels_attributes: [:access_level, :id],
#                                            push_access_levels_attributes: [:access_level, :id])
# end


# TODO:
# params.require(:runner).permit(Ci::Runner::FORM_EDITABLE)

# TODO:
# params.require(:list).permit(:position).merge(id: params[:id])

# TODO:
# allowed_fields = NotificationSetting::EMAIL_EVENTS.dup
# allowed_fields << :level
# params.require(:notification_setting).permit(allowed_fields)

# TODO:
# def project_params
#   project_feature_attributes =
#     {
#       project_feature_attributes:
#         [
#           :issues_access_level, :builds_access_level,
#           :wiki_access_level, :merge_requests_access_level, :snippets_access_level
#         ]
#     }
#
#   params.require(:project).permit(
#     :name, :path, :description, :issues_tracker, :tag_list, :runners_token,
#     :container_registry_enabled,
#     :issues_tracker_id, :default_branch,
#     :visibility_level, :import_url, :last_activity_at, :namespace_id, :avatar,
#     :build_allow_git_fetch, :build_timeout_in_minutes, :build_coverage_regex,
#     :public_builds, :only_allow_merge_if_build_succeeds, :request_access_enabled,
#     :lfs_enabled, project_feature_attributes
#   )
# end

# TODO:
# def configure_permitted_parameters
#   devise_parameter_sanitizer.permit(:sign_in, keys: [:username, :email, :password, :login, :remember_me, :otp_attempt])
# end

# TODO:
# def auth_params
#   params.permit(:service, :scope, :account, :client_id)
# end

# TODO:
# def application_params
#   params[:doorkeeper_application].permit(:name, :redirect_uri)
# end

# TODO:
# def service_params
#   dynamic_params = @service.event_channel_names + @service.event_names
#   service_params = params.permit(:id, service: ALLOWED_PARAMS + dynamic_params)
#
#   if service_params[:service].is_a?(Hash)
#     FILTER_BLANK_PARAMS.each do |param|
#       service_params[:service].delete(param) if service_params[:service][param].blank?
#     end
#   end
#
#   service_params
# end

# TODO:
# def project_params
#   params.require(:variable).permit([:id, :key, :value, :_destroy])
# end

# TODO:
# def issue_params
#   params.require(:issue).permit(
#     :title, :assignee_id, :position, :description, :confidential,
#     :milestone_id, :due_date, :state_event, :task_num, :lock_version, label_ids: []
#   )
# end

# TODO:
# def application_setting_params
#   restricted_levels = params[:application_setting][:restricted_visibility_levels]
#   if restricted_levels.nil?
#     params[:application_setting][:restricted_visibility_levels] = []
#   else
#     restricted_levels.map! do |level|
#       level.to_i
#     end
#   end
#
#   import_sources = params[:application_setting][:import_sources]
#   if import_sources.nil?
#     params[:application_setting][:import_sources] = []
#   else
#     import_sources.map! do |source|
#       source.to_str
#     end
#   end
#
#   enabled_oauth_sign_in_sources = params[:application_setting].delete(:enabled_oauth_sign_in_sources)
#
#   params[:application_setting][:disabled_oauth_sign_in_sources] =
#     AuthHelper.button_based_providers.map(&:to_s) -
#     Array(enabled_oauth_sign_in_sources)
#   params.delete(:domain_blacklist_raw) if params[:domain_blacklist_file]
#
#   params.require(:application_setting).permit(
#     :default_projects_limit,
#     :default_branch_protection,
#     :signup_enabled,
#     :signin_enabled,
#     :require_two_factor_authentication,
#     :two_factor_grace_period,
#     :gravatar_enabled,
#     :sign_in_text,
#     :after_sign_up_text,
#     :help_page_text,
#     :home_page_url,
#     :after_sign_out_path,
#     :max_attachment_size,
#     :session_expire_delay,
#     :default_project_visibility,
#     :default_snippet_visibility,
#     :default_group_visibility,
#     :domain_whitelist_raw,
#     :domain_blacklist_enabled,
#     :domain_blacklist_raw,
#     :domain_blacklist_file,
#     :version_check_enabled,
#     :admin_notification_email,
#     :user_oauth_applications,
#     :user_default_external,
#     :shared_runners_enabled,
#     :shared_runners_text,
#     :max_artifacts_size,
#     :metrics_enabled,
#     :metrics_host,
#     :metrics_port,
#     :metrics_pool_size,
#     :metrics_timeout,
#     :metrics_method_call_threshold,
#     :metrics_sample_interval,
#     :recaptcha_enabled,
#     :recaptcha_site_key,
#     :recaptcha_private_key,
#     :sentry_enabled,
#     :sentry_dsn,
#     :akismet_enabled,
#     :akismet_api_key,
#     :koding_enabled,
#     :koding_url,
#     :email_author_in_body,
#     :repository_checks_enabled,
#     :metrics_packet_size,
#     :send_user_confirmation_email,
#     :container_registry_token_expire_delay,
#     :repository_storage,
#     :enabled_git_access_protocol,
#     restricted_visibility_levels: [],
#     import_sources: [],
#     disabled_oauth_sign_in_sources: []
#   )
# end
