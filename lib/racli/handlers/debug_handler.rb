require 'racli/handlers/base'

module Racli
  module Handlers
    class DebugHandler < Base
      def call(status, headers, body, original_args)
        puts '*** debug ***'
        puts status
        puts headers
        puts body
        puts '******'
        [status, headers, body]
      end
    end
  end
end
