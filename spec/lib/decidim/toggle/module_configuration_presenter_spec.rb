# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe ModuleConfigurationPresenter do
      let(:organization) { create(:organization) }

      let(:demo_form_class) do
        Class.new(Decidim::Form) do
          mimic :organization

          attribute :enabled, :boolean
          attribute :tags, :array
          attribute :meta, :hash
        end
      end

      def build_presenter(attrs)
        form = demo_form_class.from_params(organization: attrs).with_context(current_organization: organization)
        described_class.new(form)
      end

      it "normalizes nil array to empty array" do
        p = build_presenter(tags: nil)
        expect(p.tags).to eq([])
      end

      it "normalizes nil hash to empty hash" do
        p = build_presenter(meta: nil)
        expect(p.meta).to eq({})
      end

      it "normalizes nil boolean to false and exposes predicate" do
        p = build_presenter(enabled: nil)
        expect(p.enabled).to be(false)
        expect(p.enabled?).to be(false)
      end

      it "preserves true boolean" do
        p = build_presenter(enabled: true)
        expect(p.enabled).to be(true)
        expect(p.enabled?).to be(true)
      end
    end
  end
end
