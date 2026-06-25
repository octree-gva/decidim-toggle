# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe InformativeCallouts do
      let(:form_class) do
        Class.new(Decidim::Form) do
          include InformativeCallouts

          mimic :organization

          info "Always visible"
          warning "Conditional", if_predicate: ->(form) { form.show_warning? }

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

      it "resolves message from a symbol or proc" do
        dynamic_form_class = Class.new(Decidim::Form) do
          include InformativeCallouts

          info :symbol_message
          warning ->(form) { "Proc #{form.flag}" }

          def symbol_message
            "From symbol"
          end

          attr_accessor :flag
        end

        form = dynamic_form_class.from_params({})
        form.flag = "ok"
        entries = form.visible_informative_callouts

        expect(entries[0].message_for(form)).to eq("From symbol")
        expect(entries[1].message_for(form)).to eq("Proc ok")
      end
    end
  end
end
