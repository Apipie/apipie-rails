module Apipie
  module Client
    class CliCommand < Thor
      no_tasks do
        def client
          resource_class = apipie_options[:client_module]::Resources.const_get(self.class.name[/[^:]*$/])
          @client        ||= resource_class.new(apipie_options[:config])
        end

        def transform_options(inline_params, transform_hash = { })
          # we use not mentioned params without change
          transformed_options = (options.keys - transform_hash.values.flatten - inline_params).reduce({ }) { |h, k| h.update(k => options[k]) }

          inline_params.each { |p| transformed_options[p] = options[p] }

          transform_hash.each do |sub_key, params|
            transformed_options[sub_key] = { }
            params.each { |p| transformed_options[sub_key][p] = options[p] if options.has_key?(p) }
          end

          return transformed_options
        end

        def print_data(data)
          case data
            when Array
              print_big_table(table_from_array(data))
            when Hash
              print_table(table_from_hash(data))
            else
              print_unknown(data)
          end
        end

        # unifies the data for further processing. e.g.
        #
        #     { "user" => {"username" => "test", "password" => "changeme" }
        #
        # becomes:
        #
        #     { "username" => "test", "password" => "changeme" }
        def normalize_item_data(item)
          if item.size == 1 && item.values.first.is_a?(Hash)
            item.values.first
          else
            item
          end
        end

        def table_from_array(data)
          return [] if data.empty?
          table   = []
          items   = data.map { |item| normalize_item_data(item) }
          columns = items.first.keys
          table << columns
          items.each do |item|
            row = columns.map { |c| item[c] }
            table << row.map(&:to_s)
          end
          return table
        end

        def table_from_hash(data)
          return [] if data.empty?
          table = []
          normalize_item_data(data).each do |k, v|
            table << ["#{k}:", v].map(&:to_s)
          end
          table
        end

        def print_unknown(data)
          say data
        end

        def print_big_table(table, options={ })
          return if table.empty?

          formats, ident, colwidth = [], options[:ident].to_i, options[:colwidth]
          options[:truncate] = terminal_width if options[:truncate] == true

          formats << "%-#{colwidth + 2}s" if colwidth
          start = colwidth ? 1 : 0

          start.upto(table.first.length - 2) do |i|
            maxima ||= table.max { |a, b| a[i].size <=> b[i].size }[i].size
            formats << "%-#{maxima + 2}s"
          end

          formats << "%s"
          formats[0] = formats[0].insert(0, " " * ident)

          header_printed = false
          table.each do |row|
            sentence = ""

            row.each_with_index do |column, i|
              sentence << formats[i] % column.to_s
            end

            sentence = truncate(sentence, options[:truncate]) if options[:truncate]
            $stdout.puts sentence
            say(set_color("-" * sentence.size, :green)) unless header_printed
            header_printed = true
          end
        end

      end

      class << self
        def help(shell, subcommand = true)
          list = self.printable_tasks(true, subcommand)
          Thor::Util.thor_classes_in(self).each do |klass|
            list += printable_tasks(false)
          end
          list.sort! { |a, b| a[0] <=> b[0] }

          shell.say
          shell.print_table(list, :indent => 2, :truncate => true)
          shell.say
          Thor.send(:class_options_help, shell)
        end

        def banner(task, namespace = nil, subcommand = false)
          task.name
        end
      end
    end
  end
end
