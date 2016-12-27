require 'haml'
require_relative 'controller_matcher_generator_helper'
require 'controller/action_controller/action_controller_controller_sm_model'
require 'spin_to_win'

module ShouldaMatchmakers
  class ControllerMatcherGenerator < Rails::Generators::Base

    include Generator::ActionController::ControllerMatcherGeneratorHelper

    source_root(File.expand_path(File.dirname(__FILE__)))

    class_option :include, type:    :array,
                           require: false,
                           aliases: '-i',
                           default: [],
                           desc:    "Sets list of application ActionController controllers to INCLUDE in generated tests.\n" +
                                    "                                              By default, tests are generated for all ActionController::Base descendants.\n" +
                                    "                                              When used, '_included' and '_excluded' settings in '~/config/initializers/shoulda_matchmakers.rb'\n" +
                                    "                                              configuration file are ignored. Example (space delimited, include namespaces):\n\n" +
                                    "                                              -i DriversController LicensesController Vehicle::CarsController Vehicle::BusesController\n\n\n"

    class_option :exclude, type:    :array,
                           require: false,
                           aliases: '-e',
                           default: [],
                           desc:    "Sets list of application ActionController controllers to EXCLUDE from generated tests.\n" +
                                    "                                              By default, no ActionController::Base descendants are excluded from generated tests.\n" +
                                    "                                              When used, '_included' and '_excluded' settings in '~/config/initializers/shoulda_matchmakers.rb'\n" +
                                    "                                              configuration file are ignored. Example (space delimited, include namespaces):\n\n" +
                                    "                                              -e DriversController Vehicle::CarsController\n\n\n"

    class_option :include_and_config, type:    :array,
                                       require: false,
                                       aliases: '-I',
                                       default: [],
                                       desc:    "Same as '-i/-include', except that '_included' and '_excluded' settings in\n" +
                                                "                                              '~/config/initializers/shoulda_matchmakers.rb' are not ignored. Configuration file\n" +
                                                "                                              settings are applied first then the controller names listed with this option are applied.\n" +
                                                "                                              Example (space delimited, include namespaces):\n\n" +
                                                "                                              -I DriversController LicensesController Vehicle::CarsController Vehicle::BusesController\n\n\n"

    class_option :exclude_and_config, type:    :array,
                                       require: false,
                                       aliases: '-E',
                                       default: [],
                                       desc:    "Same as '-e/-exclude', except that '_included' and '_excluded' settings in\n" +
                                                "                                              '~/config/initializers/shoulda_matchmakers.rb' are not ignored. Configuration file\n" +
                                                "                                              settings are applied first then the controller names listed with this option are applied.\n" +
                                                "                                              Example (space delimited, include namespaces):\n\n" +
                                                "                                              -E DriversController Vehicle::CarsController\n\n\n"

    def create_controller_matchmakers
      puts "\n"
      generator_options = options.to_hash
      working_generated_code_line_length = ShouldaMatchmakers.configuration.preferred_generated_code_line_length - 6
      SpinToWin.with_spinner('ShouldaMatchmakers:ControllerMatchers') do |spinner|
        spinner.banner('initializing...')
        load_application
        @app_action_controller_descendants_names = get_app_action_controller_descendants_names
      end
      puts "\n"
      generate_action_controller_controller_matchmakers(generator_options, @app_action_controller_descendants_names, working_generated_code_line_length)
    end


    private

    def generate_action_controller_controller_matchmakers(generator_options, app_action_controller_descendants_names, code_line_length)
      if app_action_controller_descendants_names.present?
        selected_app_action_controller_descendants_names = filter_app_action_controller_descendants_names(app_action_controller_descendants_names, generator_options)
        selected_app_action_controller_descendants_names.each do |app_controller_name|
          save_generate(app_controller_name) do
            @action_controller_controller_sm_model = ::ShouldaMatchmakers::Controller::ActionController::ActionControllerControllerSmModel.new(app_controller_name, app_action_controller_descendants_names, code_line_length)
            template_filename = File.expand_path('../../templates/controller/action_controller/controller_spec_template.haml', File.dirname(__FILE__))
            template = File.read(template_filename)
            create_file "#{ ShouldaMatchmakers.configuration.action_controller_controller_tests_path }/#{ app_controller_name.underscore }_spec.rb",
              Haml::Engine.new(template, filename: template_filename, format: :html5).to_html(binding)
          end
        end
      end
    end


  end
end

