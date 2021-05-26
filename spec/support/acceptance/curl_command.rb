# based on https://github.com/theforeman/puppet-pulpcore/blob/master/spec/support/acceptance/curl_command.rb
# written by https://github.com/ekohl
# https://github.com/mizzy/serverspec/pull/611 was rejected so adding it here.
begin
  require 'serverspec'

  module Serverspec
    module Type
      class CurlCommand < Command
        def response_code
          m = %r{Response-Code: (?<code>\d+)}.match(stderr)
          return 0 unless m
          m[:code].to_i
        end

        def body
          command_result.stdout
        end

        def body_as_json
          MultiJson.load(body)
        end

        private

        def curl_command
          command = "curl --silent --write-out '%{stderr}Response-Code: %{response_code}\\n' '#{@name}'"

          @options.each do |option, value|
            case option
            when :cacert, :cert, :key
              command += " --#{option} '#{value}'"
            when :headers
              value.each do |header, header_value|
                command += if header_value
                             " --header '#{header}: #{header_value}'"
                           else
                             " --header '#{header};'"
                           end
              end
            else
              raise "Unknown option #{option} (value: #{value})"
            end
          end

          command
        end

        def command_result
          @command_result ||= @runner.run_command(curl_command)
        end
      end
    end

    module Helper
      module Type
        def curl_command(*args)
          Serverspec::Type::CurlCommand.new(*args)
        end
      end
    end
  end
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # serverspec not present - usually in unit tests
end
