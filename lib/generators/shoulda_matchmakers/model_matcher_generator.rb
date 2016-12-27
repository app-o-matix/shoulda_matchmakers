require 'haml'
require_relative 'model_matcher_generator_helper'
require 'model/active_record/active_record_model_sm_model'
require 'spin_to_win'

module ShouldaMatchmakers
  class ModelMatcherGenerator < ::Rails::Generators::Base

    include Generator::ActiveRecord::ModelMatcherGeneratorHelper

    source_root(File.expand_path(File.dirname(__FILE__)))

    class_option :include, type:    :array,
                           require: false,
                           aliases: '-i',
                           default: [],
                           desc:    "Sets list of application ActiveRecord models to INCLUDE in generated tests.\n" +
                                    "                                              By default, tests are generated for all ActiveRecord::Base descendant classes.\n" +
                                    "                                              When used, '_included' and '_excluded' settings in '~/config/initializers/shoulda_matchmakers.rb'\n" +
                                    "                                              configuration file are ignored. Example (space delimited, include namespaces):\n\n" +
                                    "                                              -i Driver License Vehicle::Car Vehicle::Bus\n\n\n"

    class_option :exclude, type:    :array,
                           require: false,
                           aliases: '-e',
                           default: [],
                           desc:    "Sets list of application ActiveRecord models to EXCLUDE from generated tests.\n" +
                                    "                                              By default, no ActiveRecord::Base descendant classes are excluded from generated tests.\n" +
                                    "                                              When used, '_included' and '_excluded' settings in '~/config/initializers/shoulda_matchmakers.rb'\n" +
                                    "                                              configuration file are ignored. Example (space delimited, include namespaces):\n\n" +
                                    "                                              -e Driver Vehicle::Car\n\n\n"

    class_option :include_and_config, type:    :array,
                                       require: false,
                                       aliases: '-I',
                                       default: [],
                                       desc:    "Same as '-i/-include', except that '_included' and '_excluded' settings in\n" +
                                                "                                              '~/config/initializers/shoulda_matchmakers.rb' are not ignored. Configuration file\n" +
                                                "                                              settings are applied first then the class names listed with this option are applied.\n" +
                                                "                                              Example (space delimited, include namespaces):\n\n" +
                                                "                                              -I Driver License Vehicle::Car Vehicle::Bus\n\n\n"

    class_option :exclude_and_config, type:    :array,
                                       require: false,
                                       aliases: '-E',
                                       default: [],
                                       desc:    "Same as '-e/-exclude', except that '_included' and '_excluded' settings in\n" +
                                                "                                              '~/config/initializers/shoulda_matchmakers.rb' are not ignored. Configuration file\n" +
                                                "                                              settings are applied first then the class names listed with this option are applied.\n" +
                                                "                                              Example (space delimited, include namespaces):\n\n" +
                                                "                                              -E Driver Vehicle::Car\n\n\n"

    def create_model_matchmakers
      puts "\n"
      generator = "model"
      generator_options = options.to_hash
      working_generated_code_line_length = ::ShouldaMatchmakers.configuration.preferred_generated_code_line_length - 6
      SpinToWin.with_spinner('ShouldaMatchmakers:ModelMatchers') do |spinner|
        spinner.banner('initializing...')
        load_application
        @app_active_record_descendants_names = get_app_active_record_descendants_names
      end
      puts "\n"
      generate_active_record_model_matchmakers(generator, generator_options, @app_active_record_descendants_names, working_generated_code_line_length)
    end


    private

    def generate_active_record_model_matchmakers(generator, generator_options, app_active_record_descendants_names, code_line_length)
      if app_active_record_descendants_names.present?
        selected_app_active_record_descendants_names = filter_app_active_record_descendants_names(generator, generator_options, app_active_record_descendants_names)
        selected_app_active_record_descendants_names.each do |app_class_name|
          save_generate(app_class_name, generator) do
            @active_record_model_sm_model = ::ShouldaMatchmakers::Model::ActiveRecord::ActiveRecordModelSmModel.new(app_class_name, app_active_record_descendants_names, code_line_length)
            template_filename = File.expand_path('../../templates/model/active_record/model_spec_template.haml', File.dirname(__FILE__))
            template = File.read(template_filename)
            create_file "#{ ::ShouldaMatchmakers.configuration.active_record_model_tests_path }/#{ app_class_name.underscore }_spec.rb",
              Haml::Engine.new(template, filename: template_filename, format: :html5).to_html(binding)
          end
        end
      end
    end

  end
end

