# frozen_string_literal: true

module Racli
  module Handlers
    class Base
      attr_accessor :cli

      def initialize(cli)
        @cli = cli
      end
    end
  end
end
