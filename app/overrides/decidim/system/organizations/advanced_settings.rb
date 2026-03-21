# frozen_string_literal: true

# Replace the "Show advanced settings" button with the tabbed partial
Deface::Override.new(
  virtual_path: "decidim/system/organizations/edit",
  name: "decidim_toggle_replace_advanced_settings_button",
  replace_contents: "erb[loud]:contains('decidim_form_for')",
  closing_selector: "erb[silent]:contains('end')",
  text: '<%= render partial: "decidim_toggle/system/organizations/settings_tabs", locals: { organization: @organization } %>'
)
