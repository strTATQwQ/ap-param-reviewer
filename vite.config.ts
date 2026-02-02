import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { HttpsProxyAgent } from 'https-proxy-agent';

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: {
    proxy: {
      '/google-api': {
        target: 'https://generativelanguage.googleapis.com',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/google-api/, ''),
        agent: new HttpsProxyAgent('http://10.100.89.64:10811')
      }
    }
  }
});