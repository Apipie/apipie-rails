# frozen_string_literal: true

gem "minitest"
require "minitest/focus"
require "minitest/hooks"

require "fileutils"

require "mime/type"
ENV["RUBY_MIME_TYPES_LAZY_LOAD"] = "yes"
