# frozen_string_literal: true

require_relative 'duel_helper'

# Promises, on the immediate executor, so each callback runs in the
# benchmark's thread as its future resolves: what's measured is the
# futures' own work (states, callbacks, zipping), not a thread pool's.
# Futures on the thread pools are in executor_duel.rb.

duel 'promises: fulfilled_future with two thens' do
  Concurrent::Promises.fulfilled_future(1, :immediate).then(&:succ).then(&:succ).value!
end

duel 'promises: a chain of ten thens' do
  future = Concurrent::Promises.fulfilled_future(1, :immediate)
  10.times { future = future.then(&:succ) }
  future.value!
end

duel 'promises: zip three fulfilled futures' do
  once { @futures = Array.new(3) { |i| Concurrent::Promises.fulfilled_future(i, :immediate) } }
  Concurrent::Promises.zip(*@futures).value!
end

# The graph in examples/benchmark_new_futures.rb: ten rounds of two
# branches zipped back together.
duel 'promises: ten rounds of branching and zipping' do
  head = Concurrent::Promises.fulfilled_future(1, :immediate)
  10.times do
    branch1 = head.then(&:succ)
    branch2 = head.then(&:succ).then(&:succ)
    head = (branch1 & branch2).then { |a, b| a + b }
  end
  head.value!
end

duel 'promises: fulfill a resolvable future with a callback' do
  future = Concurrent::Promises.resolvable_future_on(:immediate)
  result = future.then(&:succ)
  future.fulfill(1)
  result.value!
end

duel 'promises: rescue a rejected future' do
  once { @error = StandardError.new('failed') }
  Concurrent::Promises.rejected_future(@error, :immediate).rescue { |error| error.message }.value!
end

duel 'promises: any of three futures' do
  once { @futures = Array.new(3) { |i| Concurrent::Promises.fulfilled_future(i, :immediate) } }
  Concurrent::Promises.any(*@futures).value!
end
