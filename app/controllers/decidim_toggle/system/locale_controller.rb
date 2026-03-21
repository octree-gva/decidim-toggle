# frozen_string_literal: true

module DecidimToggle
  module System
    class LocaleController < Decidim::System::ApplicationController
      def update
        @organization = Decidim::Organization.find(params[:organization_id])
        @form = form(Decidim::Toggle::UpdateLocaleForm).from_params(params[:organization] || {}).with_context(current_organization: @organization)

        Decidim::Toggle::UpdateLocaleCommand.new(@organization, @form).call do
          on(:ok) do
            flash[:notice] = t(".success", scope: "decidim_toggle.system.organizations.language_tab")
            redirect_to decidim_system.edit_organization_path(@organization)
          end

          on(:invalid) do
            flash[:alert] = @form.errors.full_messages.join(". ")
            redirect_to decidim_system.edit_organization_path(@organization)
          end
        end
      end
    end
  end
end
