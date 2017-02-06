module QueBus
  module Listener

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        job = Class.new(Que::Job) do
          def run(*args)
            ActiveRecord::Base.transaction do
              method = self.class.parent.get_execution_method
              final_args = case args[0]
                when Hash
                  args[0].merge(topic: args[1]["topic"])
                else
                  [args[0], args[1]["topic"]]
                end
              self.class.parent.send(method, final_args)
              destroy
            end
          end
        end
        base.const_set(:Job, job)

      end
    end

    def record_event_id(args)
      QueBus::Event.create(id: SecureRandom.uuid, subscriber: self.class.subscription_id)
    end

    def has_run?(args)
      QueBus::Event.where(id: args["event_id"], subscriber: self.class.subscription_id).count > 0
    end

    module ClassMethods
      def subscribe
        bus = QueBus::Bus.new
        bus.subscribe id: self.subscription_id, class: self::Job, topics: self.topics_list
      end

      def subscription_id
        "#{QueBus.subscription_namespace}/#{self.name}"
      end

      def topics(*topics)
        @topics = topics
      end

      def topics_list
        @topics
      end

      def exec_method(method)
        @method = method
      end

      def get_execution_method
        @method || :run
      end
    end
  end
end
