require 'active_support/core_ext/class/attribute'

module Barbarian


  class Agent

    class Context
      include Celluloid
      def initialize(horde, klass, options)
        @horde, @klass, @options = horde, klass, options
      end

      def run
        @klass.new(@options).run
        @horde.async.run_completed(Actor.current)
      end
    end

    class_attribute :path
    class_attribute :states
    self.path = {}
    self.states = {}

    attr_reader :session
    attr_accessor :sleep_enabled

    def initialize(options={})
      @session = Mechanize.new
      @session.follow_redirect = true
      self.sleep_enabled = options[:sleep_enabled]
    end

    def sleep(amount, override_sleep_enabled=nil)
      if self.sleep_enabled || override_sleep_enabled
        amount = amount + rand(amount/5.0) - amount/10.0
        Celluloid.sleep(amount)
      end
    end

    def run
      state_name = path[:initial]
      while state_name != :finished
        @state = states[state_name]
        if @state
          puts "executing state #{state_name}"
          @state.execute(self)
          state_name = case next_state = path[state_name]
          when Symbol then next_state
          when Proc then next_state.call(self)
          when Array #array of pairs, first is the state name, and the second is the weight
                    #if you pass just a symbol, that is equivalent to  [symbol,1]
            total_weight = 0
            states_with_range = []
            next_state.each do |(state, weight)|
              weight ||= 1
              states_with_range << [state, total_weight...total_weight+weight]
              total_weight += weight
            end
            value = rand(total_weight)
            states_with_range.detect {|(state, range)| range.include?(value)}.first
          else 
            next_state
          end
          unless state_name.is_a?(Symbol)
            raise "unknown state #{state_name} returned from next state #{next_state}"
          end
        else
          raise "#{state_name} is not a known state"
        end
      end
    end

    # helpers

    def form_at(css_selector)
      Mechanize::Form.new(session.page.at(css_selector), session, session.page)
    end

    def check_path(expected)
      if expected != session.page.uri.path
        raise "Expected to be on #{expected} but was on #{session.page.uri}"
      end
    end


    class << self

      def state(name, &block)
        state = State.new(name, block)
        self.states = states.merge(name => state)
      end

      def transition(args={})
        raise ":from and :to options are required" unless args[:from] && args[:to]
        self.path = path.merge(args[:from] => args[:to])
      end
    end

    class State < Struct.new(:name, :body)
      def execute(agent)
        agent.instance_eval(&body)
      end
    end

  end
end