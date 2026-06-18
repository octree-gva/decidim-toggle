# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SettingsTabItem do
      it "detects form tabs and optional partials" do
        with_partial = described_class.new(:c, "L", partial: "p/x", form_class: String, command_class: Integer)
        form = described_class.new(:f, "L", form_class: String, command_class: Integer)
        expect(with_partial.partial).to eq("p/x")
        expect(with_partial).to be_form_tab
        expect(form).to be_form_tab
      end

      it "respects open? and visible?" do
        open = described_class.new(:a, "A", open: true, if: true)
        hidden = described_class.new(:b, "B", if: false)
        expect(open).to be_open
        expect(open).to be_visible
        expect(hidden).not_to be_visible
      end

      it "exposes extra_locals" do
        item = described_class.new(:a, "A", extra_locals: { x: 1 })
        expect(item.extra_locals).to eq(x: 1)
      end

      it "allows form tab with custom layout partial" do
        item = described_class.new(
          :lang,
          "L",
          form_class: String,
          command_class: Integer,
          form_layout_partial: "decidim_toggle/system/organizations/tabs/language_tab"
        )
        expect(item).to be_form_tab
        expect(item.form_layout_partial).to include("language_tab")
      end
    end
  end
end
