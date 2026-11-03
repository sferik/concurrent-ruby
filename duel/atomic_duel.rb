# frozen_string_literal: true

require_relative 'duel_helper'

# The atomics. On CRuby with the C extension built (as it is here, and
# for anyone with concurrent-ruby-ext), AtomicReference, AtomicFixnum and
# AtomicBoolean are its C classes. Without it, they're the Mutex*
# classes in Ruby, so those are benchmarked by name too.

duel 'atomic reference: get and set' do
  once { @reference = Concurrent::AtomicReference.new(:a) }
  @reference.set(:b)
  @reference.get
end

duel 'atomic reference: update' do
  once { @reference = Concurrent::AtomicReference.new(0) }
  @reference.update { |value| value + 1 }
end

# A number goes through AtomicNumericCompareAndSetWrapper, in Ruby, with
# the C extension too.
duel 'atomic reference: compare_and_set a number' do
  once { @reference = Concurrent::AtomicReference.new(1) }
  @reference.compare_and_set(1, 2)
  @reference.compare_and_set(2, 1)
end

duel 'atomic fixnum: increment and decrement' do
  once { @fixnum = Concurrent::AtomicFixnum.new(0) }
  @fixnum.increment
  @fixnum.decrement
end

duel 'atomic fixnum: update' do
  once { @fixnum = Concurrent::AtomicFixnum.new(0) }
  @fixnum.update { |value| value + 1 }
end

duel 'atomic boolean: make_true and make_false' do
  once { @boolean = Concurrent::AtomicBoolean.new }
  @boolean.make_true
  @boolean.make_false
end

duel 'mutex atomic reference: update' do
  once { @reference = Concurrent::MutexAtomicReference.new(0) }
  @reference.update { |value| value + 1 }
end

duel 'mutex atomic fixnum: increment and decrement' do
  once { @fixnum = Concurrent::MutexAtomicFixnum.new(0) }
  @fixnum.increment
  @fixnum.decrement
end

duel 'mutex atomic boolean: make_true and make_false' do
  once { @boolean = Concurrent::MutexAtomicBoolean.new }
  @boolean.make_true
  @boolean.make_false
end

# Read on every lock and unlock of a ReentrantReadWriteLock.
duel 'thread local var: value and value=' do
  once { @var = Concurrent::ThreadLocalVar.new(0) }
  @var.value = @var.value + 1
end

duel 'monotonic time: read the clock' do
  Concurrent.monotonic_time
end
