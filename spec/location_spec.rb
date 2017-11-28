require 'location.rb'

describe SnED100::Location do
  let(:new_location) { SnED100::Location.new(:errors => Shared.error_codes, :size => [ 500, 500 ]) }

  describe "initialize" do
    context "when no size is provided" do
      it "raises error" do
        expect { SnED100::Location.new(:errors => Shared.error_codes) }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_SIZE
      end
    end

    context "when no error_codes is provided" do
      it "raises error" do
        expect { SnED100::Location.new(:size => [ 500, 500 ]) }.to raise_error RuntimeError, "ErrorCodes is required"
      end
    end
  end

  describe "#size" do
    it "returns size" do
      expect(new_location.size).to be == [ 500, 500 ]
    end
  end

  describe "#valid_position?" do
    it "returns true" do
      expect(new_location.valid_position? [ 50, 60 ]).to be true
    end

    it "returns false" do
      expect(new_location.valid_position? [ 600, 60 ]).to be false
    end
  end

  describe "#distance" do
    context "when positions are passed" do
      it "returns the distance" do
        expect(new_location.distance([ 0, 0 ], [ 4, 3 ]).to_i).to be 5
      end
    end

    context "when names are passed" do
      it "returns the distance" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]
        location.insert_at "xpto2", [ 15, 15 ]

        expect(new_location.distance("xpto", "xpto2")).to be >= 7
      end
    end
  end

  describe "#project" do
    it "returns the new position" do
      expect(new_location.project([ 0, 0 ], [ 5, 5 ], 20)).to be == [ 5, 5 ]
    end
  end

  describe "#position" do
    it "returns the position" do
      location = new_location

      location.insert_at "xpto", [ 10, 10 ]

      expect(location.position "xpto").to be == [ 10, 10 ]
    end

    it "returns nil" do
      expect(new_location.position "xpto").to be_nil
    end
  end

  describe "remove" do
    it "returns the position removed" do
      location = new_location

      location.insert_at "xpto", [ 10, 10 ]

      expect(location.remove "xpto").to be == [ 10, 10 ]
    end

    it "returns nil" do
      expect(new_location.remove "xpto").to be_nil
    end
  end

  describe "move_to" do
    it "returns the new position" do
      location = new_location

      location.insert_at "xpto", [ 10, 10 ]

      expect(location.move_to "xpto", [ 20, 30 ]).to be == [ 20, 30 ]
    end

    context "when position is outside the limit" do
      it "returns nil" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]

        expect(location.move_to "xpto", [ -20, 30 ]).to be_nil
      end
    end

    context "when the position is occupied" do
      it "returns nil" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]
        location.insert_at "xpto2", [ 20, 30 ]

        expect(location.move_to "xpto", [ 20, 30 ]).to be_nil
      end
    end
  end

  describe "#targets_in_area" do
    context "when two Entities are inside the area" do
      it "returns two names" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]
        location.insert_at "xpto2", [ 15, 15 ]

        expect(location.targets_in_area [ 12, 12 ], 5).to be == [ "xpto", "xpto2" ]
      end
    end

    context "when a name is provided and EA is zero" do
      it "returns one name" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]
        location.insert_at "xpto2", [ 15, 15 ]

        expect(location.targets_in_area "xpto", 0).to be == [ "xpto" ]
      end
    end
  end

  describe "#visible_to" do
    context "Entities visible to xpto with 10m" do
      it "returns the name, position and distance of xpto2" do
        location = new_location

        location.insert_at "xpto", [ 10, 10 ]
        location.insert_at "xpto2", [ 15, 15 ]
        location.insert_at "xpto3", [ 30, 30 ]

        distance1 = location.distance("xpto", "xpto2").ceil
        distance2 = location.distance("xpto", "xpto3").ceil

        expect(location.visible_to "xpto", 10).to be == [ ["xpto2", [ 15, 15 ], distance1 ] ]
      end
    end
  end

  describe "#approach" do
    it "returns a position in range" do
      location = new_location

      location.insert_at "xpto", [ 10, 10 ]

      expect(location.approach("xpto", [ 15,15 ], 2)).to be == [ 14, 14 ]
    end
  end
end
