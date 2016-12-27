if defined?(ShouldaMatchmakers) && Rails.env.test?

  ShouldaMatchmakers.configure do |config|

    ## MODELS

    # Path for ActiveRecord model generated test files
    #   Default is 'spec/shoulda_matchmakers/models' so as not to overwrite your existing tests
    #
    # config.active_record_model_tests_path = 'spec/shoulda_matchmakers/models/active_record'

    # Class names of ActiveRecord models to INCLUDE in the generation of tests.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(Driver License Vehicle::Car Vehicle::Bus)
    #
    #   By default, ShouldaMatchmakers model test generator includes all ActiveRecord::Base.descendants
    #   If values are set for this option AND the 'config.active_record_class_names_excluded' option,
    #   this option will be applied and the '_excluded' option will be ignored.
    #
    # config.active_record_class_names_included = %w()

    # Class names of ActiveRecord models to EXCLUDE from the generation of tests.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(Driver Vehicle::Car)
    #
    #   By default, ShouldaMatchmakers model test generator excludes no ActiveRecord::Base.descendants
    #   If values are set for this option and the 'config.active_record_class_names_included' option,
    #   the '_included' option will be applied and this option will be ignored.
    #
    # config.active_record_class_names_excluded = %w()


    ## CONTROLLERS

    # Path for ActionController controller generated test files
    #   Default is 'spec/shoulda_matchmakers/controllers' so as not to overwrite your existing tests
    #
    # config.action_controller_controller_tests_path = 'spec/shoulda_matchmakers/controllers/action_controller'

    # Names of ActionController controllers to INCLUDE in the generation of tests.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(DriversController LicensesController Vehicle::CarsController Vehicle::BusesController)
    #
    #   By default, ShouldaMatchmakers controller test generator includes all ActionController::Base.descendants.
    #   If values are set for this option AND the 'config.action_controller_controller_names_excluded' option,
    #   this option will be applied and the '_excluded' option will be ignored.
    #
    # config.action_controller_controller_names_included = %w()

    # Names of ActionController controllers to EXCLUDE from the generation of tests.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(DriversController Vehicle::CarsController)
    #
    #   By default, ShouldaMatchmakers controller test generator excludes no ActionController::Base.descendants.
    #   If values are set for this option AND the 'config.action_controller_controller_names_included' option,
    #   the '_included' option will be applied and this option will be ignored.
    #
    # config.action_controller_controller_names_excluded = %w()


    ## FACTORIES

    # Path for ActiveRecord model generated factory files
    #   Default is 'spec/shoulda_matchmakers/factories' so as not to overwrite your existing factories
    #
    # config.active_record_model_factories_path = 'spec/shoulda_matchmakers/factories/active_record'

    # Class names of ActiveRecord models to INCLUDE in the generation of factories.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(Driver License Vehicle::Car Vehicle::Bus)
    #
    #   By default, the ShouldaMatchmakers factory generator includes all ActiveRecord::Base.descendants.
    #   If values are set for this option AND the 'config.active_record_models_for_factories_excluded'
    #   option, this option will be applied and the '_excluded' option will be ignored.
    #
    # config.active_record_model_class_names_for_factories_included = %w()

    # Class names of ActiveRecord models to EXCLUDE from the generation of factories.
    #   Configuration value should be an array of String (include namespaces)
    #   Example: %w(Driver Vehicle::Car)
    #
    #   By default, the ShouldaMatchmakers factory generator excludes no ActiveRecord::Base.descendants.
    #   If values are set for this option AND the 'config.active_record_models_for_factories_included'
    #   option, the '_included' option will be applied and this option will be ignored.
    #
    # config.active_record_model_class_names_for_factories_excluded = %w()


    ## SHOULDA MATCHMAKERS SETTINGS

    # Enables generation of tests for enums (Rails 4.0+).
    #   If your version is below Rails 4, set this option to false.
    #   Default sets this option to true.
    #
    # config.include_enums = true

    # Preferred length of generated code lines
    #   Wherever possible, generated code lines will be broken into multiple lines to keep lines under
    #   your preferred length.
    #   The default value is '120' characters.
    #
    #   Note: Due to the fact that tests and factories are generated dynamically, lead spacing/tabbing
    #   for each generated line of code is difficult to predict. Therefore, your preferred line length
    #   may, at times, be exceeded as a result of this varying indentation. It may also be exceeded if
    #   there is an inability to break a line further, either due to syntax rules or for the preservation
    #   of readability. If line length is critical, account for this variation in the value you choose.
    #
    # config.preferred_generated_code_line_length = 120

  end

end
