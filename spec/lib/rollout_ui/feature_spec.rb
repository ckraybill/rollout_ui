require 'spec_helper'

describe RolloutUi::Feature do
  before do
    # Request a feature to prime RolloutUi::Wrapper rollout instance
    $rollout.active?(:featureA, double(:user, :id => 5))

    @feature = RolloutUi::Feature.new(:featureA)
  end

  describe "#percentage" do
    it "returns the activated percentage for the feature" do
      $rollout.activate_percentage(:featureA, 75)
      expect(@feature.percentage).to eq("75")
    end
  end

  describe "#percentage=" do
    it "sets the activated percentage for the feature" do
      @feature.percentage = 90
      expect(RolloutUi::Feature.new(:featureA).percentage).to eq("90")
    end
  end

  describe "#groups" do

    it "returns an empty array when there are no activated groups for the feature" do
      $redis.del('feature:featureA:groups')
      expect(@feature.groups).to eq([])
    end

    it "returns the activated groups for the feature" do
      $rollout.activate_group(:featureA, :beta_testers)
      expect(@feature.groups).to eq([:beta_testers])
    end
  end

  describe "#groups=" do
    it "sets the activated groups for the feature" do
      @feature.groups = ["all", "admins"]
      expect(RolloutUi::Feature.new(:featureA).groups).to match_array([:admins, :all])
    end
  end

  describe "#users" do
    it "returns an empty array when there are no activated users for the feature" do
      $redis.del('=feature:featureA:users')
      expect(@feature.user_ids).to eq([])
    end

    it "returns the activated users for the feature" do
      $rollout.activate_user(:featureA, double(:user, :id => 5))
      expect(@feature.user_ids).to eq(["5"])
    end
  end

  describe "#users=" do
    it "sets the activated users for the feature" do
      @feature.user_ids = [5, "7", ""]
      expect(RolloutUi::Feature.new(:featureA).user_ids.length).to eq(2)
      expect(RolloutUi::Feature.new(:featureA).user_ids).to include("5")
      expect(RolloutUi::Feature.new(:featureA).user_ids).to include("7")
    end
  end
end
