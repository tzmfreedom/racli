# frozen_string_literal: true

require 'racli/handlers/base'

module Racli
  module Handlers
    class RetryHandler < Base
      DEFAULT_MAX_RETRY_COUNTER = 3

      attr_accessor :retry_counter, :default_max_retry_counter

      def initialize(cli)
        @retry_counter = 0
        @retry_max_counter = DEFAULT_MAX_RETRY_COUNTER
        super
      end

      def call(status, headers, body, original_args)
        if (300...400).cover?(status.to_i) && headers['Location']
          unless within_max_retry_count?
            STDERR.puts 'Too many redirection!'
            throw :abort
          end
          @retry_counter += 1
          original_args[:method] = 'GET'
          original_args[:path]   = headers['Location']
          cli.call(**original_args)
          throw :abort
        end
        [status, headers, body]
      end

      def within_max_retry_count?
        @retry_counter < DEFAULT_MAX_RETRY_COUNTER
      end
    end
  end
end
