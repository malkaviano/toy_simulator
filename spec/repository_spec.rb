require_relative "../infra/repository"

class RepositoryTest
  class << self
    include Generics::Repository
  end
end

describe Generics::Repository do
  let(:object) do
    db = double("object")
    allow(db).to receive(:name).and_return("xpto")
    db
  end

  before(:each) do
    RepositoryTest.clear
  end

  describe "#add" do
    it "adds an object" do
      expect { RepositoryTest.add(object) }.to_not raise_error
    end

    it "raises error" do
      obj = object

      RepositoryTest.add(obj)

      expect { RepositoryTest.add(obj) }.to raise_error RuntimeError, "object already exists"
    end
  end

  describe "#remove" do
    it "return an object" do
      obj = object

      RepositoryTest.add(obj)

      expect(RepositoryTest.remove(obj.name)).to equal obj
      expect(RepositoryTest.find obj.name).to be_nil
    end

    it "returns nil" do
      expect(RepositoryTest.remove(:something)).to be_nil
    end
  end

  describe "#all" do
    it "returns every object" do
      obj = object

      RepositoryTest.add(obj)

      expect(RepositoryTest.all[0]).to equal obj
    end
  end

  describe "#find" do
    it "returns an object" do
      obj = object

      RepositoryTest.add(obj)

      expect(RepositoryTest.find obj.name).to equal obj
    end

    it "returns nil" do
      expect(RepositoryTest.find :noting).to be_nil
    end
  end
end
