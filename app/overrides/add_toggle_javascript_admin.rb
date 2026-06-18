# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "layouts/decidim/admin/_header",
  name: "toggle_add_javascript_config_admin",
  insert_after: "erb[loud]:contains('append_stylesheet_pack_tag')",
  original: '<%= append_stylesheet_pack_tag "decidim_admin_overrides", media: "all" %>',
  text: <<~ERB
    <%= render partial: "layouts/decidim/toggle/javascript_config" %>
  ERB
)
