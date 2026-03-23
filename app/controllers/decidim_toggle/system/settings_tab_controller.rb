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
        @form = form(form_class).from_params(params.permit!).with_context(current_organization: @organization)

        command_class.call(@organization, @form) do
          on(:ok) do
            flash[:notice] = t("decidim_toggle.system.organizations.form_tab.success")
            redirect_to settings_tab_redirect_target
          end

          on(:invalid) do
            flash[:alert] = @form.errors.full_messages.join(". ")
            redirect_to settings_tab_redirect_target
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

      def settings_tab_redirect_target
        anchor = tab_anchor_fragment
        return decidim_system.edit_organization_path(@organization) if anchor.blank?

        decidim_system.edit_organization_path(@organization, anchor:)
      end

      def tab_anchor_fragment
        tab_id = params[:decidim_toggle_active_tab].presence
        return nil unless tab_id

        tabs = Decidim::Toggle::SettingsTabs.new(:organization_settings)
        tabs.build_for(self)
        return nil unless tabs.items.any? { |item| item.identifier.to_s == tab_id.to_s }

        "panel-toggle-#{tab_id}"
      end
    end
  end
end
