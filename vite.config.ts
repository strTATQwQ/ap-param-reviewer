import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  base: '/ap-param-reviewer/',
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 寮哄埗 Rollup 妫€鏌ユā鍧?
    modulePreload: { polyfill: true }
  }
});