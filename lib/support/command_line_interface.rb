require 'slop'
require 'json'

class CLI

  # set up defaults in its own method
  def cli_flags
    options = Slop::Options.new
    options.banner =  "usage: RAILS_ENV=test rails generate shoulda_matchmakers:model [options] ...\n" +
                      "       RAILS_ENV=test rails generate shoulda_matchmakers:controller [options] ...\n" +
                      "       RAILS_ENV=test rails generate shoulda_matchmakers:factory [options] ..."

    options.separator ""
    options.separator "Options (in order of precedence):"

    options.null      "-ci",    "--config_included",  "Lists models/controllers included in the shoulda_matchmakers configuration file"

    options.array     "-i []",  "--include []",       "User entered array of names of models/controllers for which to generate matchmakers\n" +
                                                      "  All models in apps/models and controllers in apps/controllers are\nincluded by default.\n" +
                                                      " (When this option is used, the '_included' and '_excluded' settings\nin the configuration file are ignored.)",
                      delimiter: ','

    options.array     "-ii []", "--include_plus []",  "User entered array of names of models/controllers to include after\nconfiguration file inclusions/exclusions have been applied.",
                      delimiter: ','

    options.null      "-ce",    "--config_excluded",  "List of models/controllers excluded in the shoulda_matchmakers configuration file"

    options.array     "-e []",  "--exclude []",       "  User entered array of names of models/controllers for which to\nnot generate matchmakers\n" +
                                                      "  No models/controllers in apps/models and apps/controllers are\nexcluded by default.\n" +
                                                      " (If this option is used, the '_included' and '_excluded' settings\nin the configuration file are ignored.\n" +
                                                      "  If the 'include' option is used, this option is ignored.)",
                      delimiter: ','

    options.array     "-ee []", "--exclude_plus []",  "User entered array of names of models/controllers to exclude after\nconfiguration file inclusions/exclusions have been applied.",
                      delimiter: ','

    options.null      "-h",     "--help",             "Displays this list of options"

    options
  end

  def parse_arguments(command_line_options, parser)
    begin
      # slop has the advantage over optparse that it can do strings and not just ARGV
      result = parser.parse command_line_options
      result.to_hash

    # Very important to not bury this begin/rescue logic in another method
    # otherwise it will be difficult to check to see if -h or --help was passed
    # in this case -h acts as an unknown option as long as we don't define it
    # in cli_flags.
    rescue Slop::UnknownOption
      # print help
      puts cli_flags
      exit
      # If, for your program, you can't exit here, then reraise Slop::UnknownOption
      # raise a custom exception, push the rescue up to main or track that "help was invoked"
    end
  end

  def flags
    [:ce, :ci, :e, :ee, :h, :i, :ii]
  end

  def set?(arguments, flag)
    !arguments.fetch(flag).nil?
  end

  # main style entry point
  def main(command_line_options=ARGV)
    parser = Slop::Parser.new cli_flags
    arguments = parse_arguments(command_line_options, parser)

    if arguments.key?(:ce) || arguments.key?(:ci) || arguments.key?(:h)
      if arguments.key?(:ci)

      end
      if arguments.key?(:ce)

      end
      if arguments.key?(:h)
        puts cli_flags
      end
      exit
    end

    elsif set?(arguments, :port)
      puts portquiz arguments[:port]
    elsif set?(arguments, :down)
      puts is_it_up arguments[:down]
    end
  end



end

# this kind of sucks, you shouldn't ever change your code to accomodate tests
# but this is a main
# CLI.new.main if !defined?(RSpec)
