# frozen_string_literal: true

module Decidim
  module Toggle
    class SettingsTabRegistry
      class << self
        def register(name, &block)
          registry = find(name) || create(name)
          registry.configurations << block
          registry
        end

        def find(name)
          all[name.to_sym]
        end

        def create(name)
          all[name.to_sym] = new(name)
        end

        def destroy(name)
          all[name.to_sym] = nil
        end

        private

        def all
          @all ||= {}
        end
      end

      attr_reader :configurations, :form_tabs, :module_configs, :registry_name

      def initialize(name)
        @registry_name = name.to_sym
        @configurations = []
        @form_tabs = {}
        @module_configs = {}
        @tab_to_module_name = {}
        @configurations_applied = false
      end

      def mark_configurations_applied!
        @configurations_applied = true
      end

      # Runs registered +settings_tabs+ blocks so +register_form_tab+ / +module_configs+ are populated
      # (e.g. for {Decidim::Toggle.config_for} before any HTTP request builds tabs).
      def ensure_configurations_applied!
        return if @configurations_applied

        ctx = Object.new
        ctx.define_singleton_method(:t) { |key, **kw| I18n.t(key, **kw) }
        SettingsTabs.new(@registry_name).build_for(ctx)
      end

      # Last registration for a given +identifier+ wins (used when an extension replaces a tab).
      # When +module_name+ is set, last registration for that module name wins (same as tab id).
      def register_form_tab(identifier, form_class, command_class, module_name: nil)
        tid = identifier.to_sym
        if (previous = @tab_to_module_name[tid])
          @module_configs.delete(previous)
        end

        @form_tabs[tid] = { form: form_class, command: command_class }
        if module_name.blank?
          @tab_to_module_name.delete(tid)
          return
        end

        key = module_name.to_s
        @module_configs[key] = {
          form: form_class,
          command: command_class,
          tab_identifier: tid
        }
        @tab_to_module_name[tid] = key
      end

      def form_tab(identifier)
        form_tabs[identifier.to_sym]
      end

      # @return [Hash, nil] +:form+, +:command+, +:tab_identifier+ when an +add_tab+ registered this +module_name+
      def form_tab_for_module(module_name)
        ensure_configurations_applied!
        module_configs[module_name.to_s]
      end
    end
  end
end
