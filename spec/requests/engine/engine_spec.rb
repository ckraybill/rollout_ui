require 'spec_helper'

describe "Engine" do
  describe "GET /rollout" do
    let(:user) { double(:user, :id => 5) }

    before do
      $rollout.active?(:featureA, user)
    end

    it "shows requested rollout features" do
      visit "/rollout"

      expect(page).to have_content("featureA")
    end

    describe "percentage" do
      it "allows changing of the percentage" do
        visit "/rollout"

        within("#featureA .percentage_form") do
          select "100", :from => "percentage"
          click_button "Save"
        end

        expect($rollout.active?(:featureA, user)).to be_truthy
      end

      it "shows the selected percentage" do
        visit "/rollout"

        within("#featureA .percentage_form") do
          select "57", :from => "percentage"
          click_button "Save"
        end

        expect(page).to have_css(".percentage option[selected='selected']", :text => "57")
      end
    end

    describe "groups" do
      before do
        allow(user).to receive(:beta_tester?) { true }
        $rollout.define_group(:beta_testers) { |user| user.beta_tester? }
      end

      it "allows selecting of groups" do
        visit "/rollout"

        within("#featureA .groups_form") do
          select "beta_testers", :from => "groups[]"
          click_button "Save"
        end

        expect($rollout.active?(:featureA, user)).to be_truthy
      end

      it "shows the selected groups" do
        visit "/rollout"

        within("#featureA .groups_form") do
          select "beta_testers", :from => "groups[]"
          click_button "Save"
        end

        expect(page).to have_css(".groups option[selected='selected']", :text => "beta_testers")
      end
    end

    describe "users" do
      it "allows adding user ids" do
        visit "/rollout"

        within("#featureA .users_form") do
          fill_in "users[]", :with => 5
          click_button "Save"
        end

        expect($rollout.active?(:featureA, user)).to be_truthy
      end

      it "shows the selected percentage" do
        visit "/rollout"

        within("#featureA .users_form") do
          fill_in "users[]", :with => 5
          click_button "Save"
        end

        expect(page).to have_css("input.users[value='5']")
      end
    end

    describe "order" do
      before do
        $rollout.active?(:featureB, user)
        $rollout.active?(:anotherFeature, user)
      end

      it "shows features in alphabetical order" do
        visit "/rollout"

        elements = %w(anotherFeature featureA featureB)
        expect(page.body).to match(Regexp.new("#{elements.join('.*')}.*", Regexp::MULTILINE))
      end
    end
  end
end

