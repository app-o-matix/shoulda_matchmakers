module ShouldaMatchmakers
  module Generator
    module ActionController
      module ControllerMatcherGeneratorHelper

        def load_application
          Rails.application.try(:eager_load!)
        end

        def get_app_action_controller_descendants_names
          if defined?(::ActionController::Base)
            ::ActionController::Base.descendants.map(&:name)
          else
            []
          end
        end

        def save_generate(controller_name)
          begin
            yield
          rescue => e
            puts "Cannot create controller spec for #{ controller_name }. Reason #{ e.message }"
          end
        end

        def filter_app_action_controller_descendants_names(app_action_controller_descendants_names, generator_options)
          generator_include_option_action_controller_controller_names = generator_options.fetch('include')
          generator_exclude_option_action_controller_controller_names = generator_options.fetch('exclude')
          generator_include_and_config_options_action_controller_controller_names = generator_options.fetch('include_and_config')
          generator_exclude_and_config_options_action_controller_controller_names = generator_options.fetch('exclude_and_config')
          if generator_include_option_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_include_option(app_action_controller_descendants_names, generator_include_option_action_controller_controller_names)
          elsif generator_exclude_option_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_exclude_option(app_action_controller_descendants_names, generator_exclude_option_action_controller_controller_names)
          elsif generator_include_and_config_options_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_generator_include_and_config_options(app_action_controller_descendants_names, generator_include_and_config_options_action_controller_controller_names)
          elsif generator_exclude_and_config_options_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_generator_exclude_and_config_options(app_action_controller_descendants_names, generator_exclude_and_config_options_action_controller_controller_names)
          else
            selected_app_action_controller_descendants_names = filter_action_controller_controller_names_with_config_options(app_action_controller_descendants_names)
            if selected_app_action_controller_descendants_names.present?
              selected_app_action_controller_descendants_names
            else
              app_action_controller_descendants_names.uniq.sort
            end
          end

        end

        def filter_action_controller_controller_names_with_include_option(app_action_controller_descendants_names, include_option_action_controller_controller_names)
          app_action_controller_descendants_names.map.select { |app_controller_name| include_option_action_controller_controller_names.include? app_controller_name }.uniq.sort
        end

        def filter_action_controller_controller_names_with_exclude_option(app_action_controller_descendants_names, exclude_option_action_controller_controller_names)
          app_action_controller_descendants_names.map.reject { |app_controller_name| exclude_option_action_controller_controller_names.include? app_controller_name }.uniq.sort
        end

        def filter_action_controller_controller_names_with_generator_include_and_config_options(app_action_controller_descendants_names, generator_include_and_config_options_action_controller_controller_names)
          selected_app_action_controller_descendants_names = filter_action_controller_controller_names_with_config_options(app_action_controller_descendants_names)
          if selected_app_action_controller_descendants_names.present?
            selected_app_action_controller_descendants_names +
              filter_action_controller_controller_names_with_include_option(app_action_controller_descendants_names, generator_include_and_config_options_action_controller_controller_names).uniq.sort
          else
            filter_action_controller_controller_names_with_include_option(app_action_controller_descendants_names, generator_include_and_config_options_action_controller_controller_names).uniq.sort
          end
        end

        def filter_action_controller_controller_names_with_generator_exclude_and_config_options(app_action_controller_descendants_names, generator_exclude_and_config_options_action_controller_controller_names)
          selected_action_controller_controller_names = filter_action_controller_controller_names_with_config_options(app_action_controller_descendants_names)
          if selected_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_exclude_option(selected_action_controller_controller_names, generator_exclude_and_config_options_action_controller_controller_names).uniq.sort
          else
            filter_action_controller_controller_names_with_exclude_option(app_action_controller_descendants_names, generator_exclude_and_config_options_action_controller_controller_names).uniq.sort
          end
        end

        def filter_action_controller_controller_names_with_config_options(app_action_controller_descendants_names)
          config_included_option_action_controller_controller_names = ShouldaMatchmakers.configuration.action_controller_controller_names_included
          config_excluded_option_action_controller_controller_names = ShouldaMatchmakers.configuration.action_controller_controller_names_excluded
          if config_included_option_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_include_option(app_action_controller_descendants_names, config_included_option_action_controller_controller_names).uniq.sort
          elsif config_excluded_option_action_controller_controller_names.present?
            filter_action_controller_controller_names_with_exclude_option(app_action_controller_descendants_names, config_excluded_option_action_controller_controller_names).uniq.sort
          else
            []
          end
        end

      end
    end
  end
end
