require 'rubygems'
require 'bundler/setup'
require 'sidekiq'
require 'redis'

module ControlledEnqueue
  module_function

  LIST_NAME = "migrate"

  def setup(conncurrency:)
    slot_count = Redis.current.llen(LIST_NAME)
    raise "Key '#{LIST_NAME}' is being used, it already has #{slot_count} slots" if slot_count > 0

    Redis.current.lpush(LIST_NAME, conncurrency.times.to_a)

    puts "set up to have a conncurrency of #{conncurrency} slots"
  end

  def increase_concurrency(n = 1)
    Redis.current.lpush(LIST_NAME, n.times.to_a)
  end

  def decrease_concurrency(n = 1)
    n.times do
      puts "> waiting"
      Redis.current.blpop(LIST_NAME)
      puts "> decrease by 1"
    end
  end

  def nq(&block)
    while true
      puts "> waiting to enqueue"
      slot = Redis.current.blpop(LIST_NAME)
      if slot
        puts "> found slot #{slot}"
        yield
        return
      end
    end
  end

  def return_slot
    puts "> returning slot"
    Redis.current.lpush(LIST_NAME, 1)
  end

end

class HardWorker
  include Sidekiq::Worker

  def perform(user_id)
    puts "> start: #{user_id}"
    sleep 1
    puts "> finish: #{user_id}"
  ensure
    # TODO: move to middleware
    ControlledEnqueue.return_slot
  end
end
