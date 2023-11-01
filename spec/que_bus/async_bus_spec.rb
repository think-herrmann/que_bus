require 'async_spec_helper'

describe QueBus::Bus do
  describe "when we create a new bus" do
    describe "when we have a subscriber and we publish a message" do
      let(:bus) {QueBus::Bus.new }
      before do
        state = {}
        @state = state
        bus.subscribe("sub-test") do
          state[:event_received] = true
        end
        bus.publish("test")
      end

      it "receives the message" do
        eventually do
          @state[:event_received].must_equal true
        end
      end
    end

    describe "when we have a subscriber in the database that is not currently connected
      and we publish a message and then connect the subscriber" do
      let(:bus) {QueBus::Bus.new }
      before do
        state = {}
        @state = state
        QueBus::Subscriber.create(subscriber_id: "test", job_class: "QueBus::Jobs::Jobtest")
        bus.publish("reconnect_test")
        bus.subscribe("test") do
          state[:event_received] = true
        end
      end

      it "receives the message when the subscriber comes back on line" do
        eventually do
          @state[:event_received].must_equal true
        end
      end
    end
  end
end
