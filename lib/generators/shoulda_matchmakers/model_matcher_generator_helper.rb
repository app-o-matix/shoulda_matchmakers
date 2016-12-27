module ShouldaMatchmakers
  module Generator
    module ActiveRecord
      module ModelMatcherGeneratorHelper

        def load_application
          Rails.application.try(:eager_load!)
        end

        def get_app_active_record_descendants_names
          if defined?(::ActiveRecord::Base)
            ::ActiveRecord::Base.descendants.map(&:name)
          else
            []
          end
        end

        def save_generate(class_name, generator)
          begin
            yield
          rescue => e
            if generator == "model"
              puts "Cannot create model spec for #{ class_name }. Reason #{ e.message }"
            else
              puts "Cannot create factory for #{ class_name }. Reason #{ e.message }"
            end
          end
        end

        def filter_app_active_record_descendants_names(generator, generator_options, app_active_record_class_names)

          generator_include_option_active_record_class_names = generator_options.fetch('include')
          generator_exclude_option_active_record_class_names = generator_options.fetch('exclude')
          generator_include_and_config_options_active_record_class_names = generator_options.fetch('include_and_config')
          generator_exclude_and_config_options_active_record_class_names = generator_options.fetch('exclude_and_config')

          if generator_include_option_active_record_class_names.present?
            filter_active_record_class_names_with_include_option(app_active_record_class_names, generator_include_option_active_record_class_names)

          elsif generator_exclude_option_active_record_class_names.present?
            filter_active_record_class_names_with_exclude_option(app_active_record_class_names, generator_exclude_option_active_record_class_names)

          elsif generator_include_and_config_options_active_record_class_names.present?
            filter_active_record_class_names_with_generator_include_and_config_options(app_active_record_class_names, generator_include_and_config_options_active_record_class_names, generator)

          elsif generator_exclude_and_config_options_active_record_class_names.present?
            filter_active_record_class_names_with_generator_exclude_and_config_options(app_active_record_class_names, generator_exclude_and_config_options_active_record_class_names, generator)

          else
            selected_app_active_record_class_names = filter_active_record_class_names_with_config_options(app_active_record_class_names, generator)
            if selected_app_active_record_class_names.present?
              selected_app_active_record_class_names
            else
              app_active_record_class_names.uniq.sort
            end
          end

        end

        def filter_active_record_class_names_with_include_option(app_active_record_class_names, include_option_active_record_class_names)
          app_active_record_class_names.map.select { |app_class_name| include_option_active_record_class_names.include? app_class_name }.uniq.sort
        end

        def filter_active_record_class_names_with_exclude_option(app_active_record_class_names, exclude_option_active_record_class_names)
          app_active_record_class_names.map.reject { |app_class_name| exclude_option_active_record_class_names.include? app_class_name }.uniq.sort
        end

        def filter_active_record_class_names_with_generator_include_and_config_options(app_active_record_class_names, generator_include_and_config_options_active_record_class_names, generator)
          selected_app_active_record_class_names = filter_active_record_class_names_with_config_options(app_active_record_class_names, generator)
          if selected_app_active_record_class_names.present?
            selected_app_active_record_class_names +
              filter_active_record_class_names_with_include_option(app_active_record_class_names, generator_include_and_config_options_active_record_class_names).uniq.sort
          else
            filter_active_record_class_names_with_include_option(app_active_record_class_names, generator_include_and_config_options_active_record_class_names).uniq.sort
          end
        end

        def filter_active_record_class_names_with_generator_exclude_and_config_options(app_active_record_class_names, generator_exclude_and_config_options_active_record_class_names, generator)
          selected_active_record_model_names = filter_active_record_class_names_with_config_options(app_active_record_class_names, generator)
          if selected_active_record_model_names.present?
            filter_active_record_class_names_with_exclude_option(selected_active_record_model_names, generator_exclude_and_config_options_active_record_class_names).uniq.sort
          else
            filter_active_record_class_names_with_exclude_option(app_active_record_class_names, generator_exclude_and_config_options_active_record_class_names).uniq.sort
          end
        end

        def filter_active_record_class_names_with_config_options(app_active_record_class_names, generator)
          if generator == "model"
            config_included_option_active_record_class_names = ::ShouldaMatchmakers.configuration.active_record_class_names_included
            config_excluded_option_active_record_class_names = ::ShouldaMatchmakers.configuration.active_record_class_names_excluded
          else
            config_included_option_active_record_class_names = ::ShouldaMatchmakers.configuration.active_record_model_class_names_for_factories_included
            config_excluded_option_active_record_class_names = ::ShouldaMatchmakers.configuration.active_record_model_class_names_for_factories_excluded
          end
          if config_included_option_active_record_class_names.present?
            filter_active_record_class_names_with_include_option(app_active_record_class_names, config_included_option_active_record_class_names).uniq.sort
          elsif config_excluded_option_active_record_class_names.present?
            filter_active_record_class_names_with_exclude_option(app_active_record_class_names, config_excluded_option_active_record_class_names).uniq.sort
          else
            []
          end
        end

      end
    end
  end
end
