# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SettingsTabs do
      after do
        SettingsTabRegistry.destroy(:tabs_spec)
      end

      it "raises when registry is missing" do
        expect do
          described_class.new(:tabs_spec).build_for(Object.new)
        end.to raise_error(RuntimeError, /not registered/)
      end

      it "builds items from registered blocks" do
        SettingsTabRegistry.register(:tabs_spec) do |tabs|
          tabs.add_tab :one, "One", form: String, command: Integer, position: 1, module_name: :demo_mod
        end

        ctx = Object.new
        list = described_class.new(:tabs_spec)
        list.build_for(ctx)
        expect(list.items.size).to eq(1)
        expect(list.items.first.identifier).to eq(:one)
        expect(list.items.first.module_name).to eq(:demo_mod)
      end

      it "add_custom_tab registers partial tabs" do
        SettingsTabRegistry.register(:tabs_spec) do |tabs|
          tabs.add_custom_tab :x, "X", "decidim/foo", position: 2
        end

        list = described_class.new(:tabs_spec)
        list.build_for(Object.new)
        expect(list.items.first).to be_custom_tab
      end

      it "remove_tab filters items" do
        SettingsTabRegistry.register(:tabs_spec) do |tabs|
          tabs.add_tab :a, "A", form: String, command: Integer
          tabs.add_tab :b, "B", form: String, command: Integer
          tabs.remove_tab(:a)
        end

        list = described_class.new(:tabs_spec)
        list.build_for(Object.new)
        expect(list.items.map(&:identifier)).to eq([:b])
      end
    end
  end
end
