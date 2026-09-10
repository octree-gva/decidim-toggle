# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SettingsFormBuilder do
      include ActionView::TestCase::Behavior

      def build_builder(form)
        template = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new([]), {}, nil)
        described_class.new(:organization, form, template, {})
      end

      it "renders fields_for_names subset" do
        organization = create(:organization)
        form = UpdateLocaleForm.from_model(organization)
        html = build_builder(form).fields_for_names(:enable_machine_translations)
        expect(html).to be_present
      end

      it "renders informative callouts with decidim announcement cell markup" do
        form_class = Class.new(UpdateSecurityForm) do
          include InformativeCallouts

          info :spec_info_callout

          def spec_info_callout
            "Spec info callout"
          end
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
        expect(html).to include('class="decidim_toggle_informative_callout"')
      end

      it "renders i18n helptext under the field when present" do
        organization = create(:organization)
        form = UpdateSecurityForm.from_model(organization)
        builder = build_builder(form)

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

      it "disables fields when the form implements attribute_disabled?" do
        form_class = Class.new(Decidim::Form) do
          attribute :enabled, :boolean
          attribute :locked, :boolean

          def attribute_disabled?(attribute)
            attribute == :locked
          end
        end
        form = form_class.from_params(organization: { enabled: true, locked: false })
        html = build_builder(form).all_fields
        expect(html).to include('name="organization[enabled]"')
        expect(html).not_to include('organization[enabled]" disabled')
        expect(html).to include('name="organization[locked]" disabled="disabled"')
        expect(html).to include('class="field is-disabled"')
      end

      it "disables fields with disable if_unchecked and exposes data for JS" do
        form_class = Class.new(Decidim::Form) do
          include FieldConditions

          attribute :enabled, :boolean
          attribute :api_key, :string

          disable :api_key, if_unchecked: :enabled
        end
        form = form_class.from_params(organization: { enabled: false, api_key: "secret" })
        html = build_builder(form).all_fields

        expect(html).to include('name="organization[api_key]"')
        expect(html).to include('disabled="disabled"')
        expect(html).to include('data-disabled-if-unchecked="organization_enabled"')
        expect(html).to include('class="field is-disabled"')
      end

      it "renders boolean fields, text areas, and collection inputs" do
        organization = create(:organization, secondary_hosts: %w(extra.example.org))

        security_form = UpdateSecurityForm.from_model(organization)
        security_builder = build_builder(security_form)
        security_html = security_builder.all_fields
        expect(security_html).to include('type="checkbox"')
        select_html = security_builder.fields_for_names(:users_registration_mode)
        expect(select_html).to include("<select")
        expect(select_html).to include('name="organization[users_registration_mode]"')
        expect(select_html).not_to include('type="radio"')

        name_form = UpdateNameForm.from_model(organization)
        name_html = build_builder(name_form).all_fields
        expect(name_html).to include("extra.example.org")
        expect(name_html).to include('cols="55"')

        authorizations_form = UpdateAuthorizationsForm.from_model(organization)
        expect(build_builder(authorizations_form).all_fields).to include('type="checkbox"')
      end

      it "prefers instance collection methods over class methods" do
        form_class = Class.new(Decidim::Form) do
          attribute :tags, [String]

          def self.collection_for_tags
            [%w(class ClassLabel)]
          end

          def collection_for_tags
            [%w(instance InstanceLabel)]
          end
        end
        html = build_builder(form_class.from_params(organization: { tags: ["instance"] })).all_fields

        expect(html).to include("InstanceLabel")
        expect(html).not_to include("ClassLabel")
      end

      it "renders select_for collections as select dropdowns" do
        form_class = Class.new(Decidim::Form) do
          attribute :mode, :string

          def self.select_for_mode
            [%w(live Live), %w(draft Draft)]
          end
        end
        form = form_class.from_params(organization: { mode: "live" })
        html = build_builder(form).all_fields

        expect(html).to include("<select")
        expect(html).to include("Live")
        expect(html).to include("Draft")
        expect(html).not_to include('type="radio"')
      end

      it "puts field--radios / field--checkboxes on the wrapper, not inputs" do
        radio_form_class = Class.new(Decidim::Form) do
          attribute :priority, :string

          def self.collection_for_priority
            [%w(original Original), %w(translation Translation)]
          end
        end
        radio_html = build_builder(radio_form_class.from_params(organization: { priority: "original" })).all_fields
        expect(radio_html).to include('class="field field--radios"')
        expect(radio_html).to include('class="radio-field"')
        expect(radio_html).not_to match(/<input[^>]*class="[^"]*field--radios/)

        checkbox_form_class = Class.new(Decidim::Form) do
          attribute :tags, [String]

          def self.collection_for_tags
            [%w(a A), %w(b B)]
          end
        end
        checkbox_html = build_builder(checkbox_form_class.from_params(organization: { tags: ["a"] })).all_fields
        expect(checkbox_html).to include('class="field field--checkboxes"')
        expect(checkbox_html).to include('class="checkbox-field"')
        expect(checkbox_html).not_to match(/<input[^>]*class="[^"]*field--checkboxes/)
      end

      it "applies cols_for as textarea cols" do
        form_class = Class.new(Decidim::Form) do
          attribute :notes, :string

          def self.cols_for_notes
            40
          end
        end
        form = form_class.from_params(organization: { notes: "hello" })
        html = build_builder(form).all_fields

        expect(html).to include("<textarea")
        expect(html).to include('cols="40"')
      end
    end
  end
end
