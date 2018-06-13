# frozen_string_literal: true

require 'racli/handlers/base'

module Racli
  module Handlers
    class DefaultHandler < Base
      def call(status, headers, body, _original_args)
        case status.to_i
        when 200...300
          puts body[0]
        when 400...600
          STDERR.puts body[0]
        end
        [status, headers, body]
      end
    end
  end
end
