# frozen_string_literal: true

# Keys a cache keyed by string sees: a thousand of them, the same every
# time.
def keys(count = 1000)
  Array.new(count) { |i| "key-#{i}" }
end

# A Concurrent::Map holding +count+ of those keys, each to its index.
def map_of(count = 1000)
  Concurrent::Map.new.tap { |map| keys(count).each_with_index { |key, i| map[key] = i } }
end
