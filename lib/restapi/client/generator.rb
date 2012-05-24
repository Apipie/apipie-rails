#!/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'thor'
require 'thor/group'
require 'fileutils'
require 'active_support/inflector'

module Restapi
  module Client

    class Generator < Thor::Group
      include Thor::Actions
      
      # Define arguments and options
      argument :name

      attr_reader :doc, :resource

      def initialize(*args)
        super
        @doc = Restapi.to_json()[:docs]
      end
      
      def self.source_root
        File.expand_path("../template", __FILE__)
      end      

      def self.destination_root
        File.join(FileUtils.pwd, "client")
      end

      def self.start(client_name)
        super([client_name.underscore], :destination_root => destination_root)
      end

      def generate_cli
        template("README.tt", "README")
        template("Gemfile.tt", "Gemfile")
        template("bin.rb.tt", "bin/#{name}-client")
        chmod("bin/#{name}-client", 0755)
        template("client.rb.tt", "lib/#{name}_client.rb")
        template("base.rb.tt", "lib/#{name}_client/base.rb")
        template("cli_command.rb.tt", "lib/#{name}_client/cli_command.rb")
        doc[:resources].each do |key, resource|
          @resource = resource
          template("cli.rb.tt", "lib/#{name}_client/commands/#{resource_name}.thor")
          template("resource.rb.tt", "lib/#{name}_client/resources/#{resource_name}.rb")
        end
      end

      protected

      def class_base
        name.camelize
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
        client_args << "params = {}" if method[:params].any?
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
        method[:params].find_all { |p| p[:expected_type] == "hash" }.reduce({}) do |h, p|
          h.update(p[:name] => p[:params].map { |pp| pp[:name] })
        end
      end
    end
    
  end
end
