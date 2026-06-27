# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe ModuleConfigForm do
      let(:form_class) do
        Class.new(Decidim::Form) do
          include ModuleConfigForm

          self.module_config_name = "decidim_demo"

          mimic :organization

          attribute :enabled, :boolean
        end
      end

      describe ".human_attribute_name" do
        it "uses decidim_toggle.system.<module_config_name> when present" do
          I18n.with_locale(:en) do
            I18n.backend.store_translations(:en, {
                                              decidim_toggle: {
                                                system: {
                                                  decidim_demo: {
                                                    enabled: "Demo enabled label"
                                                  }
                                                }
                                              }
                                            })

            expect(form_class.human_attribute_name(:enabled)).to eq("Demo enabled label")
          end
        end

        it "falls back when the module key is missing" do
          I18n.with_locale(:en) do
            expect(form_class.human_attribute_name(:missing_attr)).to eq("Missing attr")
          end
        end
      end
    end
  end
end
