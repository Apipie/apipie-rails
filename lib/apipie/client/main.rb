require "apipie/client/thor"
require "apipie/client/cli_command"

module Apipie
  module Client
    class Main < Thor

      def help(meth = nil)
        if meth && !self.respond_to?(meth)
          initialize_thorfiles(meth)
          klass, task = Thor::Util.find_class_and_task_by_namespace(meth)
          self.class.handle_no_task_error(task, false) if klass.nil?
          klass.start(["-h", task].compact, :shell => self.shell)
        else
          say "#{apipie_options[:name].capitalize} CLI"
          say
          invoke :commands
        end
      end

      desc "commands [SEARCH]", "List the available commands"
      def commands(search="")
        initialize_thorfiles
        klasses = Thor::Base.subclasses
        display_klasses(false, false, klasses)
      end

      class << self
        private
        def dispatch(task, given_args, given_options, config)
          parser = Thor::Options.new :auth => Thor::Option.parse(%w[auth -a], :string)
          opts   = parser.parse(given_args)
          if opts['auth']
            username, password                 = opts['auth'].split(':')
            apipie_options[:config][:username] = username
            apipie_options[:config][:password] = password
          end
          remaining = parser.remaining

          super(task, remaining, given_options, config)
        end
      end

      private

      def method_missing(meth, *args)
        meth = meth.to_s
        initialize_thorfiles(meth)
        klass, task = Thor::Util.find_class_and_task_by_namespace(meth)
        args.unshift(task) if task
        klass.start(args, :shell => self.shell)
      end

      # Load the thorfiles. If relevant_to is supplied, looks for specific files
      # in the thor_root instead of loading them all.
      #
      # By default, it also traverses the current path until find Thor files, as
      # described in thorfiles. This look up can be skipped by suppliying
      # skip_lookup true.
      #
      def initialize_thorfiles(relevant_to=nil, skip_lookup=false)
        thorfiles.each do |f|
          Thor::Util.load_thorfile(f, nil, options[:debug])
        end
      end

      def thorfiles
        Dir[File.expand_path("*/commands/*.thor", apipie_options[:root])]
      end

      # Display information about the given klasses. If with_module is given,
      # it shows a table with information extracted from the yaml file.
      #
      def display_klasses(with_modules=false, show_internal=false, klasses=Thor::Base.subclasses)
        klasses -= [Thor, Main, ::Apipie::Client::CliCommand, ::Thor] unless show_internal

        show_modules if with_modules && !thor_yaml.empty?

        list   = Hash.new { |h, k| h[k] = [] }
        groups = []

        # Get classes which inherit from Thor
        (klasses - groups).each { |k| list[k.namespace.split(":").first] += k.printable_tasks(false) }

        # Get classes which inherit from Thor::Base
        groups.map! { |k| k.printable_tasks(false).first }
        list["root"] = groups

        # Order namespaces with default coming first
        list         = list.sort { |a, b| a[0].sub(/^default/, '') <=> b[0].sub(/^default/, '') }
        list.each { |n, tasks| display_tasks(n, tasks) unless tasks.empty? }
      end

      def display_tasks(namespace, list) #:nodoc:
        say namespace
      end
    end
  end

end

