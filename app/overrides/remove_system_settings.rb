# this file remove the name, host, secondary hosts, force mode, user registration mode, available authorizations from the system settings form view. 
Deface::Override.new(
  virtual_path: "decidim/system/organizations/edit",
  name: "remove_system_settings",
  replace_contents: ".form__wrapper",
  text: "<%= render partial: 'decidim_toggle/system/organizations/settings_tabs', locals: { organization: f.object, f: f } %>",
  original: "5f6f9b109a320100010000000000000000000000"
)


Deface::Override.new(
  virtual_path: "decidim/system/organizations/edit",
  name: "remove_system_settings_actions",
  remove: ".form__wrapper-block.flex-col-reverse",
  original: "5f6f9b109a320100010000000000000000000000"
)