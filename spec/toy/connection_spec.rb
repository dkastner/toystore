require 'helper'

describe Toy::Connection do
  describe "store" do
    it "should set the default store" do
      Toy.store = RedisStore
      Toy.store.should == RedisStore
    end

    it "should use the default store, if present" do
      remove_constants("Challenge")
      class Challenge
        include Toy::Store
      end
      
      Toy.store = MongoStore
      Challenge.store.should == MongoStore
    end
  end
  
  describe "logger" do
    it "should set the default logger" do
      logger = stub
      Toy.logger = logger
      Toy.logger.should == logger
    end
    
    it "should be an instance of Logger if not set" do
      Toy.logger = nil
      Toy.logger.should be_instance_of(Logger)
    end
    
    it "should use RAILS_DEFAULT_LOGGER if defined" do
      remove_constants("RAILS_DEFAULT_LOGGER")
      RAILS_DEFAULT_LOGGER = stub
            
      Toy.logger = nil
      Toy.logger.should == RAILS_DEFAULT_LOGGER
    end
    
  end
end