require 'thread'
module Barbarian
  class Horde
    def initialize(klass, count)
      @count = count
      @klass = klass
      @event_queue = Queue.new
    end

    def run
      @running = true
      @threads = 
      @count.times.collect do |index|
        sleep 0.5
        Thread.new do |t|
          while @running
            @klass.new(index).run
            @event_queue.push :kind => :run_completed
          end
        end
      end
    end

    def stop
      @running = false
      @threads.each(&:join)
    end
  end
end