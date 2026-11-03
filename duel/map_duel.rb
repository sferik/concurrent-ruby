# frozen_string_literal: true

require_relative 'duel_helper'

# Concurrent::Map is the thread-safe cache that Rails, I18n, and many
# other gems read on every request. On CRuby, a read goes straight to a
# Hash, and a write takes the map's Mutex. Each map holds a thousand
# string keys.

duel 'map: [] a present key and a missing one' do
  once { @map = map_of }
  @map['key-500']
  @map['absent']
end

duel 'map: fetch a present key, and a missing one with a default' do
  once { @map = map_of }
  @map.fetch('key-500')
  @map.fetch('absent', 0)
end

duel 'map: compute_if_absent on a present key' do
  once { @map = map_of }
  @map.compute_if_absent('key-500') { 0 }
end

duel 'map: compute_if_absent a new key, then delete it' do
  once { @map = map_of }
  @map.compute_if_absent('new') { 0 }
  @map.delete('new')
end

duel 'map: fetch_or_store on a present key' do
  once { @map = map_of }
  @map.fetch_or_store('key-500') { 0 }
end

duel 'map: fetch_or_store a new key, then delete it' do
  once { @map = map_of }
  @map.fetch_or_store('new') { 0 }
  @map.delete('new')
end

duel 'map: put_if_absent on a present key' do
  once { @map = map_of }
  @map.put_if_absent('key-500', 0)
end

duel 'map: put_if_absent a new key, then delete it' do
  once { @map = map_of }
  @map.put_if_absent('new', 0)
  @map.delete('new')
end

duel 'map: []= on a present key' do
  once { @map = map_of }
  @map['key-500'] = 1
end

duel 'map: compute a counter' do
  once { @map = Concurrent::Map.new }
  @map.compute('hits') { |hits| (hits || 0) + 1 }
end

duel 'map: [] a missing key through a default block' do
  once { @map = Concurrent::Map.new { |_map, key| key.size } }
  @map['absent']
end

duel 'map: each_pair over a thousand entries' do
  once { @map = map_of }
  @map.each_pair { |_key, value| value }
end
