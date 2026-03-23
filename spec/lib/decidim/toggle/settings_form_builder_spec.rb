# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SettingsFormBuilder do
      include ActionView::TestCase::Behavior

      it "renders all_fields from a real form" do
        organization = create(:organization)
        form = UpdateSecurityForm.from_model(organization)
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)
        builder = described_class.new(:organization, form, template, {})

        html = builder.all_fields
        expect(html).to be_present
      end

      it "renders fields_for_names subset" do
        organization = create(:organization)
        form = UpdateLocaleForm.from_model(organization)
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)
        builder = described_class.new(:organization, form, template, {})

        html = builder.fields_for_names(:enable_machine_translations)
        expect(html).to be_present
      end

      it "renders i18n helptext under the field when present" do
        organization = create(:organization)
        form = UpdateSecurityForm.from_model(organization)
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)
        builder = described_class.new(:organization, form, template, {})

        helptext = "Spec helptext for users_registration_mode"
        model_key = form.class.model_name.i18n_key.to_s

        I18n.with_locale(:en) do
          I18n.backend.store_translations(:en, {
            activemodel: {
              attributes: {
                "organization" => {
                  helptext: {
                    "users_registration_mode" => helptext
                  }
                },
                model_key => {
                  helptext: {
                    "users_registration_mode" => helptext
                  }
                }
              }
            }
          })

          html = builder.fields_for_names(:users_registration_mode)
          expect(html).to include(helptext)
        end
      end
    end
  end
end
