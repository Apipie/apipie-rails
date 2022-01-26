if RUBY_VERSION >= '2.6.0'
  if Rails.version < '5'
    # rubocop:disable Style/CommentAnnotation
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
    # rubocop:enable Style/CommentAnnotation
  end
end

