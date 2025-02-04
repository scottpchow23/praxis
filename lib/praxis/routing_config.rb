# frozen_string_literal: true

module Praxis
  class RoutingConfig
    attr_reader :route, :version, :base

    def initialize(version: 'n/a', base: '', prefix: [], &block)
      @version = version
      @base = base
      @prefix_segments = Array(prefix)

      @route = nil

      instance_eval(&block) if block_given?
    end

    def clear!
      @prefix_segments = []
    end

    def prefix(prefix = nil)
      return @prefix_segments.join.gsub('//', '/') if prefix.nil?

      case prefix
      when ''
        @prefix_segments = []
      when ABSOLUTE_PATH_REGEX
        @prefix_segments = Array(prefix[1..-1])
      else
        @prefix_segments << prefix
      end
    end

    def options(path, opts = {})
      add_route 'OPTIONS', path, opts
    end

    def get(path, opts = {})
      add_route 'GET',     path, opts
    end

    def head(path, opts = {})
      add_route 'HEAD',    path, opts
    end

    def post(path, opts = {})
      add_route 'POST',    path, opts
    end

    def put(path, opts = {})
      add_route 'PUT',     path, opts
    end

    def delete(path, opts = {})
      add_route 'DELETE',  path, opts
    end

    def trace(path, opts = {})
      add_route 'TRACE',   path, opts
    end

    def connect(path, opts = {})
      add_route 'CONNECT', path, opts
    end

    def patch(path, opts = {})
      add_route 'PATCH',   path, opts
    end

    def any(path, opts = {})
      add_route 'ANY',     path, opts
    end

    ABSOLUTE_PATH_REGEX = %r{^//}.freeze

    def add_route(verb, path, options = {})
      path = prefix + path unless path =~ ABSOLUTE_PATH_REGEX
      prefixed_path = path.gsub('//', '/')
      path = (base + path).gsub('//', '/')
      pattern = Mustermann.new(path, **{ ignore_unknown_options: true }.merge(options))
      @route = Route.new(verb, pattern, version, prefixed_path: prefixed_path, **options)
    end
  end
end
