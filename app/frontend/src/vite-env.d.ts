/// <reference types="vite/client" />

interface Window {
  __CLOUDKITE_CONFIG__?: {
    apiBaseUrl?: string;
    appVersion?: string;
    environment?: string;
  };
}
