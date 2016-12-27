module ShouldaMatchmakers
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration

    attr_accessor :active_record_class_names_included,
                  :active_record_class_names_excluded,
                  :active_record_model_tests_path,

                  :action_controller_controller_names_included,
                  :action_controller_controller_names_excluded,
                  :action_controller_controller_tests_path,

                  :active_record_model_class_names_for_factories_included,
                  :active_record_model_class_names_for_factories_excluded,
                  :active_record_model_factories_path,

                  :include_enums,
                  :preferred_generated_code_line_length

    def initialize

      @active_record_class_names_included = %w()
      @active_record_class_names_excluded = %w()
      @active_record_model_tests_path     = 'spec/shoulda_matchmakers/models/active_record'

      @action_controller_controller_names_included = %w()
      @action_controller_controller_names_excluded = %w()
      @action_controller_controller_tests_path     = 'spec/shoulda_matchmakers/controllers/action_controller'

      @active_record_model_class_names_for_factories_included = %w()
      @active_record_model_class_names_for_factories_excluded = %w()
      @active_record_model_factories_path                     = 'spec/shoulda_matchmakers/factories/active_record'

      @include_enums = true
      @preferred_generated_code_line_length = 120

    end

  end
end
