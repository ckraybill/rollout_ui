require 'spec_helper'

describe RolloutUi::Wrapper do
  before do
    @rollout_ui = RolloutUi::Wrapper.new
  end

  it "cannot be initialized without an instance of rollout if rollout hasn't been wrapped" do
    RolloutUi.wrap(nil)

    expect{ RolloutUi::Wrapper.new }.to raise_error(RolloutUi::Wrapper::NoRolloutInstance)
  end

  it "can be initialized with an instance of Rollout" do
    expect(RolloutUi::Wrapper.new($rollout)).to be_an_instance_of(RolloutUi::Wrapper)
  end

  it "can be initialized without an instance of rollout if rollout has been wrapped" do
    expect(RolloutUi::Wrapper.new).to be_an_instance_of(RolloutUi::Wrapper)
  end

  describe "#groups" do
    it "returns all groups defined for the rollout instance" do
      $rollout.define_group(:beta_testers) { |user| user.beta_tester? }

      expect(@rollout_ui.groups).to match_array([:all, :beta_testers])
    end

    it "doesn't return other defined groups" do
      Rollout.new($redis).define_group(:beta_testers) { |user| user.beta_tester? }

      expect(@rollout_ui.groups).to eq([:all])
    end
  end

  describe "#features" do
    it "returns an empty array if no features have been requested" do
      expect(@rollout_ui.features).to eq([])
    end

    it "returns all features that have been requested" do
      $rollout.active?(:featureA, double(:user, :id => 5))
      $rollout.active?(:featureB, double(:user, :id => 6))

      expect(@rollout_ui.features).to match_array(["featureA", "featureB"])
    end

    it "lists each feature only once" do
      $rollout.active?(:featureA, double(:user, :id => 5))
      $rollout.active?(:featureA, double(:user, :id => 6))

      expect(@rollout_ui.features).to eq(["featureA"])
    end

    it "lists features in alphabetical order" do
      $rollout.active?(:zFeature, double(:user, :id => 1))
      $rollout.active?(:featureA, double(:user, :id => 5))
      $rollout.active?(:featureB, double(:user, :id => 6))
      $rollout.active?(:anotherFeature, double(:user, :id => 8))

      expect(@rollout_ui.features).to match_array(%w(anotherFeature featureA featureB zFeature))
    end
  end

  describe "#add_feature" do
    it "adds feature to the list of features" do
      @rollout_ui.add_feature(:featureA)

      expect(@rollout_ui.features).to eq(["featureA"])
    end
  end
end
