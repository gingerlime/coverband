# frozen_string_literal: true

module Coverband
  class AtExit
    @semaphore = Mutex.new

    def self.register
      return if @at_exit_registered
      @semaphore.synchronize do
        return if @at_exit_registered
        @at_exit_registered = true
        at_exit do
          ::Coverband::Background.stop
          Coverband::Collectors::Coverage.instance.report_coverage(true)
          Coverband.configuration.logger&.debug('Coverband: Reported coverage before exit')
        end
      end
    end
  end
end
