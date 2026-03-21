# frozen_string_literal: true

module DecidimToggle
  module System
    class SettingsTabController < Decidim::System::ApplicationController
      def update
        build_tabs_registry
        config = registry.form_tab(params[:tab_id])
        return head :not_found unless config

        @organization = Decidim::Organization.find(params[:organization_id])
        form_class = config[:form]
        command_class = config[:command]
        @form = form(form_class).from_params(params).with_context(current_organization: @organization)

        command_class.new(@organization, @form).call do
          on(:ok) do
            flash[:notice] = t(".success", scope: "decidim_toggle.system.organizations.form_tab")
            redirect_to decidim_system.edit_organization_path(@organization)
          end

          on(:invalid) do
            flash[:alert] = @form.errors.full_messages.join(". ")
            redirect_to decidim_system.edit_organization_path(@organization)
          end
        end
      end

      private

      def build_tabs_registry
        tabs = Decidim::Toggle::SettingsTabs.new(:organization_settings)
        tabs.build_for(self)
      end

      def registry
        Decidim::Toggle::SettingsTabRegistry.find(:organization_settings)
      end
    end
  end
end
