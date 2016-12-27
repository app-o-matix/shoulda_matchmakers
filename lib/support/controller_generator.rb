require 'controller/action_controller/action_controller_controller'

module ShouldaMatchmakers
  class ControllerGenerator < Rails::Generators::Base

    source_root(File.expand_path(File.dirname(__FILE__)))

    class_option :include, type:    :array,
                           require: false,
                           aliases: '-i',
                           default: [],
                           desc:    "Allows user to enter a space-delimited list of controller names for which to generate matchmakers\n" +
                                    "                                                All controllers that are descendants of ActionController::Base are included by default.\n" +
                                    "                                                Example: -i DriversController LicensesController Vehicle::CarsController Vehicle::BusesController\n\n" +
                                    "                                                When this option is used, the '_included' and '_excluded' settings in the\n" +
                                    "                                                '~/config/initializers/shoulda_matchmakers.rb' configuration file are ignored.\n\n\n"

    class_option :exclude, type:    :array,
                           require: false,
                           aliases: '-e',
                           default: [],
                           desc:    "Allows user to enter a space-delimited list of controller names for which to not generate matchmakers\n" +
                                    "                                                No controllers that are descendants of ActionController::Base are excluded by default.\n" +
                                    "                                                Example: -e DriversController Vehicle::CarsController\n\n" +
                                    "                                                When this option is used, the '_included' and '_excluded' settings in the\n" +
                                    "                                                '~/config/initializers/shoulda_matchmakers.rb' configuration file are ignored.\n\n\n"

    class_option :include_with_config, type:    :array,
                                       require: false,
                                       aliases: '-I',
                                       default: [],
                                       desc:    "Same as '-i/-include', except that configuration file inclusions/exclusions\n" +
                                                "                                                are not ignored. Configuration file inclusions/exclusions are applied first\n" +
                                                "                                                then the controllers in the arguments list of this option are applied.\n\n\n"

    class_option :exclude_with_config, type:    :array,
                                       require: false,
                                       aliases: '-E',
                                       default: [],
                                       desc:    "Same as '-e/-exclude', except that configuration file inclusions/exclusions\n" +
                                                "                                                are not ignored. Configuration file inclusions/exclusions are applied first\n" +
                                                "                                                then the controllers in the arguments list of this option are applied.\n\n\n"

    def create_controller_matchmakers
      generator_options = options.to_hash
      load_application
      generate_controller_matchmakers(generator_options)
    end

    def load_application
      Rails.application.try(:eager_load!)
    end

    def generate_controller_matchmakers(generator_options)
      app_action_controller_descendants_names = load_action_controller_controller_names
      if app_action_controller_descendants_names.present?
        selected_action_controller_controller_names = select_action_controller_controller_names(app_action_controller_descendants_names, generator_options)
        selected_action_controller_controller_names.each do |controller_name|
          save_generate(controller_name) do
            @action_controller_controller_sm_model = ::ShouldaMatchmakers::Controller::ActionController::ActionControllerController.new(controller_name)
            template_filename = File.expand_path('vendor/shoulda_matchmakers/lib/templates/controller/action_controller/controller_spec_template.haml')
            template = File.read(template_filename)
            create_file "#{ ShouldaMatchmakers.configuration.controllers_test_path }/#{ controller_name.underscore }_spec.rb",
              Haml::Engine.new(template, filename: template_filename, format: :html5).to_html(binding)
          end
        end
      end
    end

    def load_action_controller_controller_names
      if defined?(::ActionController::Base)
        ActionController::Base.descendants.map(&:name)
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

    def select_action_controller_controller_names(app_action_controller_descendants_names, generator_options)
      generator_options_include = generator_options.fetch('include')
      generator_options_exclude = generator_options.fetch('exclude')
      generator_options_include_with_config = generator_options.fetch('include_with_config')
      generator_options_exclude_with_config = generator_options.fetch('exclude_with_config')

      if generator_options_include.present?
        select_controller_names_generator_option_include(app_action_controller_descendants_names, generator_options_include)
      elsif generator_options_exclude.present?
        select_controller_names_generator_option_exclude(app_action_controller_descendants_names, generator_options_exclude)
      elsif generator_options_include_with_config.present?
        select_controller_names_generator_option_include_with_config(app_action_controller_descendants_names, generator_options_include_with_config)
      elsif generator_options_exclude_with_config.present?
        select_controller_names_generator_option_exclude_with_config(app_action_controller_descendants_names, generator_options_exclude_with_config)
      else
        select_controller_names_config(app_action_controller_descendants_names)
      end
    end

    def select_controller_names_generator_option_include(app_action_controller_descendants_names, include_controller_names)
      app_action_controller_descendants_names.map(&:name).select { |app_controller_name| include_controller_names.include? app_controller_name }.uniq.sort
    end

    def select_controller_names_generator_option_exclude(app_action_controller_descendants_names, exclude_controller_names)
      app_action_controller_descendants_names.map(&:name).reject { |app_controller_name| exclude_controller_names.include? app_controller_name }.uniq.sort
    end

    def select_controller_names_generator_option_include_with_config(app_action_controller_descendants_names, include_with_config_controller_names)
      selected_action_controller_controller_names = select_controller_names_config(app_action_controller_descendants_names)
      if selected_action_controller_controller_names.present?
        (selected_action_controller_controller_names + app_action_controller_descendants_names.map.select { |app_controller_name| include_with_config_controller_names.include? app_controller_name }).uniq.sort
      else
        select_controller_names_generator_option_include(app_action_controller_descendants_names, include_with_config_controller_names).uniq.sort
      end
    end

    def select_controller_names_generator_option_exclude_with_config(app_action_controller_descendants_names, exclude_with_config_controller_names)
      selected_action_controller_controller_names = select_controller_names_config(app_action_controller_descendants_names)
      if selected_action_controller_controller_names.present?
        selected_action_controller_controller_names.map.reject { |app_controller_name| exclude_with_config_controller_names.include? app_controller_name }.uniq.sort
      else
        select_controller_names_generator_option_exclude(app_action_controller_descendants_names, exclude_with_config_controller_names).uniq.sort
      end
    end

    def select_controller_names_config(app_action_controller_descendants_names)
      controller_names_config_included = ShouldaMatchmakers.configuration.models_included
      controller_names_config_excluded = ShouldaMatchmakers.configuration.models_excluded
      if controller_names_config_included.present?
        selected_controller_names_config = app_action_controller_descendants_names.map.select { |app_controller_name| controller_names_config_included.include? app_controller_name }.uniq.sort
        selected_controller_names_config
      elsif controller_names_config_excluded.present?
        selected_controller_names_config = app_action_controller_descendants_names.map.reject { |app_controller_name| controller_names_config_excluded.include? app_controller_name }.uniq.sort
        selected_controller_names_config
      else
        app_action_controller_descendants_names.map.uniq.sort
      end
    end

  end
end
