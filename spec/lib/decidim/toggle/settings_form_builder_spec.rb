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

      it "renders informative callouts with decidim announcement cell markup" do
        form_class = Class.new(UpdateSecurityForm) do
          include InformativeCallouts

          info "Spec info callout"
        end
        form = form_class.from_params(organization: {})
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)
        allow(template).to receive(:cell) do |_name, message, options|
          %(<div class="flash flex-col #{options[:callout_class]}">#{message}</div>).html_safe
        end
        builder = described_class.new(:organization, form, template, {})

        html = builder.informative_callouts
        expect(html).to include("Spec info callout")
        expect(html).to include('class="flash flex-col info"')
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

      it "renders boolean fields, text areas, and collection inputs" do
        organization = create(:organization, secondary_hosts: %w(extra.example.org))
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)

        security_form = UpdateSecurityForm.from_model(organization)
        security_builder = described_class.new(:organization, security_form, template, {})
        security_html = security_builder.all_fields
        expect(security_html).to include('type="checkbox"')
        expect(security_builder.fields_for_names(:users_registration_mode)).to include('type="radio"')

        name_form = UpdateNameForm.from_model(organization)
        name_builder = described_class.new(:organization, name_form, template, {})
        expect(name_builder.all_fields).to include("extra.example.org")

        authorizations_form = UpdateAuthorizationsForm.from_model(organization)
        authorizations_builder = described_class.new(:organization, authorizations_form, template, {})
        expect(authorizations_builder.all_fields).to include('type="checkbox"')
      end
    end
  end
end
