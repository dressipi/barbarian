module Barbarian
  class Horde
    include Celluloid
    trap_exit :actor_died

    attr_reader :running

    def initialize(agent_klass, count, agent_options={})
      @count = count
      @agent_klass = agent_klass
      @agent_options = agent_options
      @failed_count  = 0
      @success_count = 0
      @running_count = 0
      @running = true
      @actors = []
    end
 
    def spawn
      actor = Agent::Context.new_link(Actor.current,@agent_klass, @agent_options)
      actor.async.run
      @running_count += 1
    end

    def actor_died(actor, reason)
      @running_count -= 1
      @failed_count += 1 if reason.is_a?(Exception)
      spawn if running
    end


    def run_completed(actor)
      @success_count += 1
      if running
        actor.async.run
      else
        actor.terminate
      end
    end

    def start
      @started = Time.now
      puts "starting #{@count} #{@agent_klass.name} agents with #{@agent_options.inspect}"
      @count.times do
        sleep 0.5
        spawn
      end
    end

    def stop
      @running = false
    end

    def running?
      @running_count > 0
    end

    def status
      duration = Time.now - @started
      "#{@running_count} agents running, #{@success_count} cycles #{@failed_count} failures in #{duration.to_i}s"
    end
  end
end