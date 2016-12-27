module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module FactorySmModelHelper


        def factory_attributes
          attributes_for_factory = get_validation_attributes(@app_class_name)
          attributes_for_factory = attributes_for_factory | get_required_attributes(@app_class_name)
          attributes_for_factory = attributes_for_factory - get_attributes_with_defaults(@app_class_name)
          attributes_for_factory = attributes_for_factory.flatten.compact.uniq.sort
          factory_attributes_string = ""
          attributes_for_factory.each do |attribute|
            factory_attributes_string.concat("    # " + attribute.to_s + "\n")
          end
          factory_attributes_string
        end


        private

        def get_validation_attributes(app_class_name)
          validation_attributes = []
          validation_attributes = validation_attributes | get_absence_attributes(app_class_name)
          validation_attributes = validation_attributes | get_acceptance_attributes(app_class_name)
          validation_attributes = validation_attributes | get_confirmation_attributes(app_class_name)
          validation_attributes = validation_attributes | get_exclusion_attributes(app_class_name)
          validation_attributes = validation_attributes | get_inclusion_attributes(app_class_name)
          validation_attributes = validation_attributes | get_length_attributes(app_class_name)
          validation_attributes = validation_attributes | get_numericality_attributes(app_class_name)
          validation_attributes = validation_attributes | get_presence_attributes(app_class_name)
          validation_attributes | get_uniqueness_attributes(app_class_name)
        end

        def get_attributes_with_defaults(app_class_name)
          app_class_name.constantize.columns.select{ |column| !column.default.nil? }.map(&:name).map(&:to_sym)
          # The following line of code doesn't work for the class 'SuperAdminUser', but only that class.
          # app_class_name.constantize.column_defaults.select{ |attribute, default| !default.nil? }.keys.map(&:to_sym)
        end

        def get_required_attributes(app_class_name)
          required_attributes = []
          required_attributes.concat(app_class_name.constantize.columns.select{ |column| !column.null }.map(&:name))
          required_attributes.map(&:to_sym) - [:id, :encrypted_password, :created_at, :updated_at]
        end

        def get_absence_attributes(app_class_name)
          absence_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::AbsenceValidator).flatten.map do |validator|
            absence_attributes.concat(validator.attributes)
          end
          absence_attributes
        end

        def get_acceptance_attributes(app_class_name)
          acceptance_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::AcceptanceValidator).flatten.map do |validator|
            acceptance_attributes.concat(validator.attributes)
          end
          acceptance_attributes
        end

        def get_confirmation_attributes(app_class_name)
          confirmation_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::ConfirmationValidator).flatten.map do |validator|
            confirmation_attributes.concat(validator.attributes)
          end
          confirmation_attributes
        end

        def get_exclusion_attributes(app_class_name)
          exclusion_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::ExclusionValidator).flatten.map do |validator|
            exclusion_attributes.concat(validator.attributes)
          end
          exclusion_attributes
        end

        def get_inclusion_attributes(app_class_name)
          inclusion_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::InclusionValidator).flatten.map do |validator|
            inclusion_attributes.concat(validator.attributes)
          end
          inclusion_attributes
        end

        def get_length_attributes(app_class_name)
          length_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::LengthValidator).flatten.map do |validator|
            length_attributes.concat(validator.attributes)
          end
          length_attributes
        end

        def get_numericality_attributes(app_class_name)
          numericality_attributes = []
          extract_validators(app_class_name, ::ActiveModel::Validations::NumericalityValidator).flatten.map do |validator|
            numericality_attributes.concat(validator.attributes)
          end
          numericality_attributes
        end

        def get_presence_attributes(app_class_name)
          presence_attributes = []
          extract_validators(app_class_name, ::ActiveRecord::Validations::PresenceValidator).flatten.map do |validator|
            presence_attributes.concat(validator.attributes)
          end
          presence_attributes
        end

        def get_uniqueness_attributes(app_class_name)
          uniqueness_attributes = []
          extract_validators(app_class_name, ::ActiveRecord::Validations::UniquenessValidator).flatten.map do |validator|
            uniqueness_attributes.concat(validator.attributes)
          end
          uniqueness_attributes
        end

      end
    end
  end
end


