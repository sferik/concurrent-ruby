# frozen_string_literal: true

require_relative 'duel_helper'

# The thread pools, where tasks run on threads of their own. Each sample
# posts its tasks and waits for the last one, so no thread is still busy
# in the next sample. Judged on timings alone (with the GVL plugin, how
# long the threads waited for the GVL too), as counts vary with how the
# threads interleave.

setup { @pool = Concurrent::FixedThreadPool.new(4) }
teardown do
  [@pool, @timers].compact.each do |executor|
    executor.shutdown
    executor.wait_for_termination
  end
end

duel 'thread pool: post a hundred tasks to four threads', only: :timing do |n|
  n.times do
    latch = Concurrent::CountDownLatch.new(100)
    100.times { @pool.post { latch.count_down } }
    latch.wait
  end
end

duel 'promises: a hundred futures on a pool, zipped', only: :timing do |n|
  n.times do
    futures = Array.new(100) { |i| Concurrent::Promises.future_on(@pool, i, &:succ) }
    Concurrent::Promises.zip_futures_on(:immediate, *futures).value!
  end
end

# Tasks an hour out, which the timer thread queues and never runs: a
# post wakes it, and a cancel takes the task out of its queue.
duel 'timer set: post ten tasks and cancel them', only: :timing do |n|
  once { @timers = Concurrent::TimerSet.new(executor: :immediate) }
  n.times do
    tasks = Array.new(10) { @timers.post(3600) { nil } }
    tasks.each(&:cancel)
  end
end

# TimerSet's queue, from one thread.
duel 'priority queue: push a hundred items and pop them' do
  once { @times = Array.new(100) { |i| (i * 37) % 100 } }
  queue = Concurrent::Collection::NonConcurrentPriorityQueue.new(order: :min)
  @times.each { |time| queue.push(time) }
  queue.pop until queue.empty?
end
