require 'racli/handlers/base'

module Racli
  module Handlers
    class DefaultHandler < Base
      def call(status, headers, body, original_args)
        case status.to_i
          when 200...300
            puts body[0]
          when 300...400

          else
            STDERR.puts body[0]
        end
        [status, headers, body]
      end
    end
  end
end
