#!/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'thor'
require 'thor/group'
require 'fileutils'
require 'active_support/inflector'

module Apipie
  module Client

    class Generator < Thor::Group
      include Thor::Actions

      # Define arguments and options
      argument :name
      argument :subject
      argument :suffix

      attr_reader :doc, :resource

      def initialize(*args)
        super
        @doc = Apipie.to_json()[:docs]
      end

      def self.source_root
        File.expand_path("../template", __FILE__)
      end

      def self.destination_root(name, suffix)
        File.join(FileUtils.pwd, "#{name}#{suffix}")
      end

      def self.start(client_name, subject = :all, suffix = '_client')
        name = client_name.parameterize.underscore
        suffix = suffix.parameterize.underscore
        super([name, subject, suffix], :destination_root => destination_root(name, suffix))
      end

      def all?
        subject == :all
      end

      def generate_cli
        full_name = "#{name}#{suffix}"
        template("README.tt", "README")
        template("Gemfile.tt", "Gemfile")
        template("Rakefile.tt", "Rakefile")
        template("client.gemspec.tt", "#{full_name}.gemspec")
        template("lib/client.rb.tt", "lib/#{full_name}.rb")
        template("lib/a_name/version.rb.tt", "lib/#{full_name}/version.rb")
        if all?
          template("bin/bin.rb.tt", "bin/#{full_name}")
          chmod("bin/#{full_name}", 0755)
        end
        doc[:resources].each do |key, resource|
          @resource = resource
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
        text.gsub(/<.*?>/, '').gsub("\n",' ').strip
      end

      # Resource related helper methods:

      def resource_name
        resource[:name].gsub(/\s/,"_").downcase.singularize
      end

      def api(method)
        method[:apis].first
      end

      def params_in_path(method)
        api(method)[:api_url].scan(/:([^\/]*)/).map(&:first)
      end

      def client_args(method)
        client_args = params_in_path(method).dup
        client_args << "params = {}"
        client_args << 'headers = {}'
        client_args
      end

      def validation_hash(method)
        if method[:params].any? { |p| p[:params] }
          method[:params].reduce({}) do |h, p|
            h.update(p[:name] => (p[:params] ? p[:params].map { |pp| pp[:name] } : nil))
          end
        else
          method[:params].map { |p| p[:name] }
        end
      end

      def substituted_url(method)
        params_in_path(method).reduce(api(method)[:api_url]) { |u, p| u.sub(":#{p}","\#{#{p}}")}
      end

      def transformation_hash(method)
        method[:params].find_all { |p| p[:expected_type] == "hash" && !p[:params].nil? }.reduce({}) do |h, p|
          h.update(p[:name] => p[:params].map { |pp| pp[:name] })
        end
      end
    end

  end
end
