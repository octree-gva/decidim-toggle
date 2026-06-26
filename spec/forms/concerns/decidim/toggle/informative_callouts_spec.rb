# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe InformativeCallouts do
      let(:form_class) do
        Class.new(Decidim::Form) do
          include InformativeCallouts

          mimic :organization

          info :always_visible_message
          warning :conditional_message, if_predicate: ->(form) { form.show_warning? }

          def always_visible_message
            "Always visible"
          end

          def conditional_message
            "Conditional"
          end

          def show_warning?
            @show_warning
          end

          attr_writer :show_warning
        end
      end

      it "registers informative entries on the form class" do
        expect(form_class.informative_callouts.map(&:type)).to eq([:info, :warning])
      end

      it "filters entries with visible_informative_callouts" do
        form = form_class.from_params({})
        form.show_warning = false

        expect(form.visible_informative_callouts.map { |entry| entry.message_for(form) }).to eq(["Always visible"])

        form.show_warning = true
        expect(form.visible_informative_callouts.map { |entry| entry.message_for(form) }).to eq(["Always visible", "Conditional"])
      end

      it "resolves the message from a form method" do
        form = form_class.from_params({})

        expect(form.visible_informative_callouts.first.message_for(form)).to eq("Always visible")
      end
    end
  end
end
