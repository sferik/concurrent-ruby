# frozen_string_literal: true

require_relative 'duel_helper'

# The older abstractions, which much code still uses: IVar under Future
# and Promise, and Delay. Each runs on the immediate executor, or in the
# caller's thread, as Delay does.

duel 'ivar: set and value' do
  Concurrent::IVar.new.set(1).value
end

duel 'future: execute and value' do
  Concurrent::Future.execute(executor: :immediate) { 1 }.value
end

duel 'promise: execute, then, and value' do
  Concurrent::Promise.execute(executor: :immediate) { 1 }.then(&:succ).value
end

duel 'delay: value, the first time and again' do
  delay = Concurrent::Delay.new { 1 }
  delay.value
  delay.value
end
