require_relative './app'

# set it up so that we can only have 3 nqed jobs at any time
# ControlledEnqueue.setup(concurrency: 3)

100.times do |i|
  ControlledEnqueue.nq do
    puts "> enqueuing user_id: #{i}"
    HardWorker.perform_async(i)
  end
end
