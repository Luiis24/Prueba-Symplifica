import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  build: {
    outDir: '../backend/src/main/resources/static',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        // Fixed (non-hashed) names so the Thymeleaf template can reference
        // them directly without needing a manifest.
        entryFileNames: 'js/main.js',
        chunkFileNames: 'js/[name].js',
        assetFileNames: ({ name }) => {
          if (/\.(gif|jpe?g|png|svg|webp)$/.test(name ?? '')) {
            return 'images/[name][extname]'
          } else if (/\.css$/.test(name ?? '')) {
            return 'css/style.css'
          }
          return '[name][extname]'
        }
      }
    }
  },
  server: {
    port: 5173,
    open: true,
    proxy: {
      '/api': 'http://localhost:8080'
    }
  }
})
