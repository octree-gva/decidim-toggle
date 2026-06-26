# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateLocaleCommand do
      let(:organization) { create(:organization) }
      let(:rebuild_search_task) { instance_double(Rake::Task, invoke: nil, reenable: nil) }

      before do
        allow(Rails.application).to receive(:load_tasks)
        allow(Rake::Task).to receive(:[]).and_call_original
        allow(Rake::Task).to receive(:[]).with("decidim:locales:rebuild_search").and_return(rebuild_search_task)
      end

      it "updates locales and rebuilds search index" do
        organization.update!(available_locales: %w(en ca), default_locale: "ca")

        expect(Rails.application).to receive(:load_tasks).ordered
        expect(rebuild_search_task).to receive(:reenable).ordered
        expect(rebuild_search_task).to receive(:invoke).ordered

        form = UpdateLocaleForm.from_params(
          organization: { available_locales: { "en" => "1" }, default_locale: "en" }
        ).with_context(current_organization: organization)

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:ok])
        organization.reload
        expect(organization.available_locales).to eq(%w(en))
        expect(organization.default_locale).to eq("en")
      end

      it "broadcasts invalid when form is invalid" do
        form = UpdateLocaleForm.from_model(organization)
        form.available_locales = []
        form.default_locale = ""

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:invalid])
      end
    end
  end
end
