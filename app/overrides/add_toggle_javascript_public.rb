# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "layouts/decidim/_decidim_javascript",
  name: "toggle_add_javascript_config_public",
  insert_after: "erb[loud]:contains('layouts/decidim/js_configuration')",
  original: '<%= render partial: "layouts/decidim/js_configuration" %>',
  text: <<~ERB
    <%= render partial: "layouts/decidim/toggle/javascript_config" %>
  ERB
)
