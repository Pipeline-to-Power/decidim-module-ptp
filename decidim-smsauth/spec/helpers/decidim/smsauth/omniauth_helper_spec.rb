# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Smsauth
    describe OmniauthHelper do
      let(:helper) do
        Class.new(ActionView::Base) do
          include OmniauthHelper
        end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
      end

      describe "#sorted_countries" do
        subject { helper.sorted_countries }

        it "adds the listed countries to the top" do
          allow(Decidim::Smsauth).to receive(:default_countries).and_return(%w(LT LU LV))
          expect(subject[0..2]).to eq(
            [
              ["Lithuania (+370)", "LT", { data: { flag_image: "/packs-test/media/images/lt-93a07daff68dea7336fd.svg" } }],
              ["Luxembourg (+352)", "LU", { data: { flag_image: "/packs-test/media/images/lu-c155a6845ad167cdad8c.svg" } }],
              ["Latvia (+371)", "LV", { data: { flag_image: "/packs-test/media/images/lv-ff6176a6bfeba64d0716.svg" } }]
            ]
          )
        end
      end
    end
  end
end
