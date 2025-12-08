import { defineConfig } from "vite"
import ViteRails from "vite-plugin-rails"
import tailwindcss from "@tailwindcss/vite"
import * as path from "path";

export default defineConfig({
  plugins: [
    tailwindcss(),
    ViteRails({
      envVars: { RAILS_ENV: "development" },
      envOptions: { defineOn: "import.meta.env" },
      fullReload: {
        additionalPaths: [
          "app/components/**/*",
          "app/helpers/**/*",
        ],
        delay: 200,
      },
    }),
  ],
  resolve: {
    alias: {
      '~fontawesome': path.resolve(__dirname, 'node_modules/@fortawesome/fontawesome-free'),
    }
  },
  build: { sourcemap: false },
})
