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

        expect(form.visible_informative_callouts.map(&:message)).to eq(["Always visible"])

        form.show_warning = true
        expect(form.visible_informative_callouts.map(&:message)).to eq(["Always visible", "Conditional"])
      end
    end
  end
end
