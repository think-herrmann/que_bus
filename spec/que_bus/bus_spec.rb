require 'spec_helper'

describe QueBus::Bus do
  describe "when we create a new bus" do

    it "initializes with default priority 100" do
      bus = QueBus::Bus.new
      expect(bus.priority).must_equal 100
    end

    it "allows setting a specific priority" do
      bus = QueBus::Bus.new(1)
      expect(bus.priority).must_equal 1
    end

    describe "and subscribe the bus" do
      let(:bus) {QueBus::Bus.new }

      let(:result) {bus.subscribe params}
      let(:params) { {} }

      it "gives us a subscription id" do
        result.wont_be_nil
      end

      describe "with our own id" do
        let(:params) {:test}

        it "gives us the same id back" do
          result.must_equal :test
        end
      end
    end

    describe "when we subscribe to the bus with a block and publish a message" do
      let(:bus) {QueBus::Bus.new }
      before do
        bus.subscribe do
          @event_recieved = true
        end
        bus.publish({test: "Test"})
      end

      it "recieved the event" do
        @event_recieved.must_equal true
      end
    end

    describe "when we subscribe to the bus with a block that takes an argument and publish a message" do
      let(:bus) {QueBus::Bus.new }
      before do
        bus.subscribe do |msg|
          @event_recieved = msg[:value]
        end
        bus.publish({value: true})
      end

      it "recieved the event" do
        @event_recieved.must_equal true
      end
    end

    describe "when we subscribe to the bus twice with a block and publish a message" do
      let(:bus) {QueBus::Bus.new }

      before do
        bus.subscribe do
          @event1_recieved = true
        end
        bus.subscribe do
          @event2_recieved = true
        end

        bus.publish({test: "test"})
      end

      it "recieves both events" do
        @event1_recieved.must_equal true
        @event2_recieved.must_equal true
      end
    end

    describe "when we subscribe in one bus and publish in a different bus" do
      let(:bus) {QueBus::Bus.new }
      before do
        bus.subscribe do
          @event_recieved = true
        end

        QueBus::Bus.new.publish("test")
      end

      it "recieves the event" do
        @event_recieved.must_equal true
      end
    end

    describe "when we subscribe to a specific channel" do
      let(:bus) {QueBus::Bus.new }
      before do
        bus.subscribe(:topics=> :foo) do
          @foo_event_called = true
        end
      end

      describe "and we publish to the same channel" do
        let(:bus) {QueBus::Bus.new }
        before do
          bus.publish("hey foo", :topic => :foo)
        end

        it "recieves the foo event" do
          @foo_event_called.must_equal true
        end
      end

      describe "and we publish on a different channel" do
        let(:bus) {QueBus::Bus.new }
        before do
          bus.publish("hey foo",:topic=> :bar)
        end

        it "does not recieve the foo event" do
          @foo_event_called.must_be_nil
        end
      end

      describe "and we publish with no defined channel" do
        let(:bus) {QueBus::Bus.new }
        before do
          bus.publish("hey foo")
        end

        it "recieves the message" do
          @foo_event_called.must_equal true
        end
      end
    end

    describe "when we subscribe to all channels" do
      let(:bus) {QueBus::Bus.new }

      before do
        bus.subscribe(:topics=> "all") do
          @foo_event_called = true
        end
      end

      describe "and we publish on any channel" do
        let(:bus) {QueBus::Bus.new }

        before do
          bus.publish("hey foo",:topic=> :bar)
        end

        it "recieves the message" do
          @foo_event_called.must_equal true
        end
      end
    end

    describe "when we subscribe to the bus with a class" do
      let(:bus) {QueBus::Bus.new }

      before do
        require 'fixtures/job_class'
        @state = {}
        bus.subscribe id: "test", class: TestClass
        bus.publish @state
      end

      it "runs the classes run method and manipuates the state" do
        @state[:event_recieved].must_equal true
      end
    end
  end
end
