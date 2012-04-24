require 'helper'

describe Toy::Dirty do
  uses_objects('User')

  before do
    User.attribute(:name, String)
  end

  it "has no changes for new with no attributes" do
    User.new.should_not be_changed
    User.new.changed.should be_empty
    User.new.changes.should be_empty
  end

  it "has changes for new with attributes" do
    user = User.new(:name => 'Geoffrey')
    user.should be_changed
    user.changed.should include('name')
    user.changes.should == {'name' => [nil, 'Geoffrey']}
  end

  it "knows attribute changed through writer" do
    user = User.new
    user.name = 'John'
    user.should be_changed
    user.changed.should include('name')
    user.changes['name'].should == [nil, 'John']
  end

  it "knows when attribute did not change" do
    user = User.new
    user.name = nil
    user.should_not be_changed
  end

  it "has attribute changed? method" do
    user = User.new
    user.should_not be_name_changed
    user.name = 'John'
    user.should be_name_changed
  end

  it "has attribute was method" do
    user = User.new(:name => 'John')
    user.name_was.should be_nil  # name changed from nil to John
  end

  it "has attribute change method" do
    user = User.new(:name => 'John')
    user.name_change.should == [nil, 'John']  # name changed from nil to John
  end

  it "has attribute will change! method" do
    user = User.new
    user.name_will_change!
    user.should be_changed
  end

  describe "#clone" do
    it "has no changes" do
      User.new.clone.should_not be_changed
    end
  end
end