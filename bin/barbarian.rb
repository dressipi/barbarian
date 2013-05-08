require 'optparse'
require 'bundler/setup'
require 'yaml'
require 'active_support/core_ext/string/inflections'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'..','lib'))
require 'barbarian'
Dir.chdir(File.join(File.dirname(__FILE__),'..','lib','agents')) do
  Dir['*.rb'].each do |name|
    require "agents/#{name.gsub('.rb','')}" 
  end
end


klass_name = nil
config_file = nil
host = nil
size = nil
sleep_enabled = false

opts = OptionParser.new do |opts|
  opts.on('-h', '--host HOST', 'Host to lay siege to') { |value| host = value}
  opts.on('--config FILE', 'Path to a config file to use') {|value| config_file = value}
  opts.on('-s', '--size INTEGER', 'number of agents to use', Integer) {|value| size = value}
  opts.on('-c', '--class ClassName', 'Name of the agent class to use') {|value| klass_name = value} 
  opts.on('--sleep', 'activate agent sleeping is enabled')  {sleep_enabled = true}
end

opts.parse!

if config_file
  config = YAML.load(File.read(config_file))
  host ||= config['host']
  size ||= config['size']
  klass_name ||= config['class']
  sleep_enabled = config['sleep'] if config.has_key?('sleep')
end

unless klass_name
  puts opts
  exit 1
end

size ||= 1
host ||= 'localhost:3000'
klass = klass_name.constantize

horde = Barbarian::Horde.new(klass, size, {:host => host, :sleep_enabled => sleep_enabled})
trap("SIGINT") { puts "shutting down...";horde.stop}
horde.start
while horde.running?
  sleep 5
  puts "Horde status: #{horde.status}"
end
puts "Horde status: #{horde.status}"
horde.terminate