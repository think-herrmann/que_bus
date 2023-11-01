module QueBus
  module Publisher
    def publish(topic, message)
      publisher.priority = message.fetch(:priority, 100)
      publisher.publish(message, topic: topic)
      messages << [topic, message]
    end

    def publisher
      @publisher ||= QueBus::Bus.new
    end

    def messages
      @message ||= []
    end
  end
end
