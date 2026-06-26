import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Decidim Toggle',
  tagline: 'Tabbed System administration — register org settings from your Decidim module',
  favicon: 'img/logo.svg',

  url: 'https://octree.ch',
  baseUrl: '/decidim-toggle/',
  trailingSlash: false,

  organizationName: 'octree-gva',
  projectName: 'decidim-toggle',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Decidim Toggle',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle',
          label: 'GitLab',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Overview',
              to: '/',
            },
            {
              label: 'Integrate',
              to: '/integrate',
            },
            {
              label: 'Contribute',
              to: '/contributing',
            },
            {
              label: 'Code of conduct',
              to: '/code-of-conduct',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitLab',
              href: 'https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle',
            },
          ],
        },
      ],
      copyright: 'Built with Docusaurus. Powered by <a href="https://voca.city">Voca</a>.',
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
