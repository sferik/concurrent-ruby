# frozen_string_literal: true

# Duel's configuration: https://github.com/sferik/duel-ruby/blob/main/docs/configuration.md
#
# Duel follows conventions, so set only what differs: benchmarks are in
# duel/**/*_duel.rb, each version's lib/ is first on the load path, a
# change is compared when it touches lib/ or ext/ (or the benchmarks, or
# this file), and releases are tagged v*.
Duel.configure do |c|
  # The library each version's workers require, from its lib/ (there's no
  # gemspec to name it). Or, to load each version some other way:
  #   c.load { |root| require File.join(root, "config", "boot") }
  # c.library = "my_library"
  #
  # The repository holds three gems, each with its own directory in lib/:
  # concurrent-ruby's code is in lib/concurrent-ruby, along with the C
  # extension (concurrent-ruby-ext's) that c.build builds into it. So each
  # version goes first on the load path from there, ahead of the
  # candidate's that Bundler put on it, and requires the whole library.
  c.load do |root|
    $LOAD_PATH.unshift(File.join(root, 'lib', 'concurrent-ruby'))
    require 'concurrent'
  end

  # Builds each version's C extension, so that each is measured with its
  # own build. The C classes take the place of AtomicReference,
  # AtomicFixnum and AtomicBoolean (which Promises and the locks use
  # inside), as for anyone with concurrent-ruby-ext installed. The Ruby
  # classes the gem falls back on without it are benchmarked by name.
  c.build = 'bundle exec rake compile'

  # How long the threads of a benchmark with threads of its own (only:
  # :timing, the thread pools') waited for the GVL.
  c.use :gvl

  # When the workflow comments on a pull request with the report: :always,
  # :results (passed or failed), :failures (failed, or couldn't compare),
  # or :never.
  # c.comment = :failures

  # Which runs a regression fails: :every_run, or :pull_requests, for a
  # project where people push to main directly (on GitHub Actions, another
  # run warns and passes, and a pushed commit gets the comment instead).
  # c.fail_on = :every_run

  # A label that accepts a regression in a pull request (nil for none).
  # c.accept_label = "duel: accept"

  # What the workflow compares a push with: :before (the commit before it),
  # or :last_passed (the last commit Duel passed, which a branch,
  # duel/passed/main, marks), so small slowdowns add up until they fail.
  # c.push_base = :before
end
