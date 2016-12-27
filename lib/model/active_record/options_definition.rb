module ShouldaMatchmakers
  module Model
    module ActiveRecord
      class OptionsDefinition



        ### Attribute Accessors ###
        attr_accessor :options_hash

        def initialize
          @options_hash = {
                                      allow_blank:              "allow_blank",
                                      allow_destroy:            "allow_destroy({ option_value })",
                                      allow_nil:                "allow_nil",
                                      autosave:                 "autosave({ option_value })",
                                      case_sensitive:           "case_insensitive",
                                      class_name:               "class_name('{ option_value }')",
                                      counter_cache:            "counter_cache({ option_value })",
                                      dependent:                "dependent(:{ option_value })",
                                      dependent_boolean:        "dependent({ option_value })",
                                      equal_to:                 "is_equal_to({ option_value })",
                                      even:                     "even",
                                      foreign_key:              "with_foreign_key('{ option_value }')",
                                      greater_than:             "is_greater_than({ option_value })",
                                      greater_than_or_equal_to: "is_greater_than_or_equal_to({ option_value })",
                                      in:                       "is_at_least({ option_value.first.to_s }).\n      is_at_most({ option_value.last.to_s })",
                                      in_array:                 "in_array({ option_value })",
                                      in_range:                 "in_range({ option_value })",
                                      inverse_of:               "inverse_of(:{ option_value })",
                                      is:                       "is_equal_to({ option_value.to_s })",
                                      join_table:               "join_table('{ option_value }')",
                                      less_than:                "is_less_than({ option_value })",
                                      less_than_or_equal_to:    "is_less_than_or_equal_to({ option_value })",
                                      limit:                    "limit({ option_value })",
                                      maximum:                  "is_at_most({ option_value.to_s })",
                                      message_double_quotes:    "with_message(\"{ option_value }\")",
                                      message_single_quotes:    "with_message('{ option_value }')",
                                      minimum:                  "is_at_least({ option_value.to_s })",
                                      odd:                      "odd",
                                      on:                       "on(:{ option_value })",
                                      only_integer:             "only_integer",
                                      order_double_quotes:      "order(\"{ option_value }\")",
                                      order_single_quotes:      "order('{ option_value }')",
                                      primary_key:              "with_primary_key('{ option_value }')",
                                      scope:                    "scoped_to({ option_value })",
                                      source:                   "source(:{ option_value })",
                                      through:                  "through(:{ option_value })",
                                      too_long_double_quotes:   "with_long_message(\"{ option_value }\")",
                                      too_long_single_quotes:   "with_long_message('{ option_value }')",
                                      too_short_double_quotes:  "with_short_message(\"{ option_value }\")",
                                      too_short_single_quotes:  "with_short_message('{ option_value }')",
                                      touch:                    "touch({ option_value })",
                                      update_only:              "update_only({ option_value })",
                                      validate:                 "validate({ option_value })"
                                    }
        end

        # else
        #    # IMPLEMENTATION TODO: Possibly handle this case option as an error or modify evaluation of option above upon return from call
        #    ""

        # ALLOW VALUE
        # IMPLEMENTATION TODO: Determine if Shoulda Matchers recognizes the 'multiline' option
        # when :multiline
        #   "multiline(#{ option_value })"

        # VALIDATE ACCEPTANCE OF
        # IMPLEMENTATION TODO: Determine if Shoulda Matchers recognizes the 'accept' option
        # when :accept
        #   "accept('#{ option_value }')"

        # VALIDATE EXCLUSION OF
        # IMPLEMENTATION TODO: Determine if 'allow_blank' is a valid option
        # when :allow_blank
        #   "allow_blank"
        # IMPLEMENTATION TODO: Determine if 'allow_nil' is a valid option
        # when :allow_nil
        #   "allow_nil"

        # VALIDATE INCLUSION OF
        # IMPLEMENTATION TODO: Determine if it is possible to implement 'with_low_message' and 'with_high_message'
        # IMPLEMENTATION TODO: Determine if 'allow_blank' is a valid option
        # when :allow_blank
        #   "allow_blank"
        # IMPLEMENTATION TODO: Determine if 'allow_nil' is a valid option
        # when :allow_nil
        #   "allow_nil"

        # VALIDATE LENGTH OF
        # IMPLEMENTATION TODO: Determine if it is possible to implement 'tokenizer'
        # IMPLEMENTATION TODO: Determine if 'allow_blank' is a valid option
        # when :allow_blank
        #   "allow_blank"
        # IMPLEMENTATION TODO: Determine if 'allow_nil' is a valid option
        # when :allow_nil
        #   "allow_nil"
        # IMPLEMENTATION TODO: Determine if Shoulda Matchers recognizes the 'wrong_length' option
        #   if option_value.include? '"'
        #     "wrong_length('#{ option_value }')"
        #   else
        #     "wrong_length(\"#{ option_value }\")"
        #   end

        # VALIDATE NUMERICALITY OF
        # IMPLEMENTATION TODO: Determine if 'allow_blank' is a valid option
        # when :allow_blank
        #   "allow_blank"
        # IMPLEMENTATION TODO: Determine if Shoulda Matchers recognizes the 'other_than' option
        # when :other_than
        #   "other_than(:#{ option_value })"

        # BELONG TO
        # IMPLEMENTATION TODO: Determine if it is possible to implement 'conditions'
        # VERIFICATION TODO: Verify capture of 'order' value due to its unique syntax (e.g. '-> { order("priority desc")' })
        # when :order
        #   if option_value.include? '"'
        #     "order('#{ option_value }')"
        #   else
        #     "order(\"#{ option_value }\")"
        #   end

        # HAVE AND BELONG TO MANY
        # VERIFICATION TODO: Verify capture of 'order' value due to its unique syntax (e.g. '-> { order("priority desc")' })
        # when :order
        #   if option_value.include? '"'
        #     "order('#{ option_value }')"
        #   else
        #     "order(\"#{ option_value }\")"
        #   end

        # HAVE MANY
        # VERIFICATION TODO: Verify capture of 'order' value due to its unique syntax (e.g. '-> { order("priority desc")' })
        # when :order
        #   if option_value.include? '"'
        #     "order('#{ option_value }')"
        #   else
        #     "order(\"#{ option_value }\")"
        #   end

        # HAVE ONE
        # IMPLEMENTATION TODO: Determine if Shoulda Matchers recognizes the 'inverse_of' option for 'have_one'
        # when :inverse_of
        #   "inverse_of(:#{ option_value })"
        # VERIFICATION TODO: Verify capture of 'order' value due to its unique syntax (e.g. '-> { order("priority desc")' })
        # when :order
        #   if option_value.include? '"'
        #     "order('#{ option_value }')"
        #   else
        #     "order(\"#{ option_value }\")"
        #   end

        # VALIDATE UNIQUENESS OF
        # IMPLEMENTATION TODO: Determine if it is possible to implement 'ignoring_case_sensitivity'


      end
    end
  end
end
