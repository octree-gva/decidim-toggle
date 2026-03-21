# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateLocaleCommand do
      let(:organization) { create(:organization) }

      before do
        task = instance_double(Rake::Task, invoke: nil, reenable: nil)
        allow(Rake::Task).to receive(:[]).and_call_original
        allow(Rake::Task).to receive(:[]).with("decidim:locales:rebuild_search").and_return(task)
      end

      it "updates locales and rebuilds search index" do
        form = UpdateLocaleForm.from_model(organization)
        form.available_locales = %w(en)
        form.default_locale = "en"

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:ok])
        expect(organization.reload.default_locale).to eq("en")
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
