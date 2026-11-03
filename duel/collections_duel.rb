# frozen_string_literal: true

require_relative 'duel_helper'

# On CRuby, Concurrent::Array and Concurrent::Hash are plain subclasses
# of Array and Hash, which the GVL keeps safe: these guard that they stay
# as fast. Concurrent::Set wraps every method in a Monitor.

duel 'array: push and pop' do
  once { @array = Concurrent::Array.new(keys(100)) }
  @array.push('key-100')
  @array.pop
end

duel 'hash: store and fetch' do
  once { @hash = Concurrent::Hash[keys(100).zip(0...100)] }
  @hash['key-50'] = 50
  @hash.fetch('key-50')
end

duel 'set: add, include? and delete' do
  once { @set = Concurrent::Set.new(keys(100)) }
  @set.add('new')
  @set.include?('key-50')
  @set.delete('new')
end
