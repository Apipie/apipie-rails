#!/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'thor'
require 'thor/group'
require 'fileutils'
require 'active_support/inflector'
require 'apipie/client/base'

module Apipie
  module Client

    class Generator < Thor::Group
      include Thor::Actions

      # Define arguments and options
      argument :name
      argument :subject
      argument :suffix
      argument :version

      attr_reader :doc, :resource, :resource_key

      def initialize(*args)
        super
        @doc = Apipie.to_json(version)[:docs]
      end

      def self.source_root
        File.expand_path("../template", __FILE__)
      end

      def self.destination_root(name, suffix)
        File.join(FileUtils.pwd, "#{name}#{suffix}")
      end

      def self.start(client_name, subject = :all, suffix = '_client', version = nil)
        name = client_name.parameterize.underscore
        suffix = suffix.parameterize.underscore
        super([name, subject, suffix, version], :destination_root => destination_root(name, suffix))
      end

      def all?
        subject == :all
      end

      def generate_cli
        full_name = "#{name}#{suffix}"
        template("README.tt", "README")
        template("Gemfile.tt", "Gemfile")
        template("Rakefile.tt", "Rakefile")
        template("a_name.gemspec.tt", "#{full_name}.gemspec")
        template("lib/a_name.rb.tt", "lib/#{full_name}.rb")
        template("lib/a_name/version.rb.tt", "lib/#{full_name}/version.rb")
        create_file "lib/#{full_name}/documentation.json", JSON.dump(Apipie.to_json)
        copy_file "lib/a_name/config.yml", "lib/#{full_name}/config.yml"
        if all?
          template("bin/bin.rb.tt", "bin/#{full_name}")
          chmod("bin/#{full_name}", 0755)
        end
        doc[:resources].each do |key, resource|
          @resource_key, @resource = key, resource
          if all?
            template("lib/a_name/commands/cli.rb.tt", "lib/#{full_name}/commands/#{resource_name}.thor")
          end
          template("lib/a_name/resources/resource.rb.tt", "lib/#{full_name}/resources/#{resource_name}.rb")
        end
      end

      protected

      def camelizer(string)
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$2.capitalize}" }
      end

      def class_base
        @class_base ||= camelizer(name)
      end

      def class_suffix
        @class_suffix ||= camelizer(suffix)
      end

      def plaintext(text)
        text.gsub(/<.*?>/, '').gsub("\n", ' ').strip
      end

      # Resource related helper methods:

      def resource_name
        resource[:name].gsub(/\s/, "_").downcase.singularize
      end

      def api(method)
        method[:apis].first
      end

      def params_in_path(method)
        api(method)[:api_url].scan(/:([^\/]*)/).map(&:first)
      end

      def client_args(method)
        params_in_path(method).dup
      end

      def substituted_url(method)
        params_in_path(method).reduce(api(method)[:api_url]) { |u, p| u.sub(":#{p}", "\#{#{p}}") }
      end

      def transformation_hash(method)
        method[:params].find_all { |p| p[:expected_type] == "hash" && !p[:params].nil? }.reduce({ }) do |h, p|
          h.update(p[:name] => p[:params].map { |pp| pp[:name] })
        end
      end

      def validation(method)
        stringify = lambda do |object|
          case object
            when Hash
              clone = object.dup
              object.keys.each { |key| clone[key.to_s] = stringify[clone.delete(key)] }
              clone
            when Array
              object.map { |value| stringify[value] }
            else
              object
          end
        end
        Apipie::Client::Base.construct_validation_hash(stringify[method])
      end
    end

  end
end
