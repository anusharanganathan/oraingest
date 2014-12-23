module Sufia
  module Resque
    class Queue
      def push_raw(job)
        # Extending Sufia queue to push json strings into redis for jobs not managed by resque
        queue = job.respond_to?(:queue_name) ? job.queue_name : default_queue_name
        begin
          $redis.lpush(queue, job.as_json)
        rescue Redis::CannotConnectError
          ActiveFedora::Base.logger.error "Redis is down!"
        end
      end
    end
  end
end
