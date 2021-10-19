module QueBus
  class Railtie < Rails::Railtie
    rake_tasks do
      load "que_bus/rake_tasks.rb"
    end

    initializer "set subscription_namespace" do
      if Rails::VERSION::MAJOR >= 6
        QueBus.subscription_namespace = Rails.application.class.module_parent_name
      else
        QueBus.subscription_namespace = Rails.application.class.parent_name
      end
    end
  end
end
