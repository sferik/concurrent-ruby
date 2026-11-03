# frozen_string_literal: true

require_relative 'duel_helper'

# Locks and the like, uncontended: what every caller pays to take and
# release them, from one thread.

duel 'reentrant read write lock: with_read_lock' do
  once { @lock = Concurrent::ReentrantReadWriteLock.new }
  @lock.with_read_lock { nil }
end

duel 'reentrant read write lock: with_write_lock' do
  once { @lock = Concurrent::ReentrantReadWriteLock.new }
  @lock.with_write_lock { nil }
end

duel 'reentrant read write lock: a read lock inside a write lock' do
  once { @lock = Concurrent::ReentrantReadWriteLock.new }
  @lock.with_write_lock { @lock.with_read_lock { nil } }
end

duel 'read write lock: with_read_lock and with_write_lock' do
  once { @lock = Concurrent::ReadWriteLock.new }
  @lock.with_read_lock { nil }
  @lock.with_write_lock { nil }
end

duel 'semaphore: acquire and release' do
  once { @semaphore = Concurrent::Semaphore.new(4) }
  @semaphore.acquire
  @semaphore.release
end

duel 'semaphore: try_acquire and release' do
  once { @semaphore = Concurrent::Semaphore.new(4) }
  @semaphore.release(2) if @semaphore.try_acquire(2)
end

duel 'count down latch: count down to zero' do
  latch = Concurrent::CountDownLatch.new(3)
  3.times { latch.count_down }
  latch.wait
end
