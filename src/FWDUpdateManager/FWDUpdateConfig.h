#pragma once

// GitHub repository configuration for auto-update
#define FWD_UPDATE_GITHUB_OWNER  "Flying-Wedge-Defence-and-Aerospace"
#define FWD_UPDATE_GITHUB_REPO   "FWD_AGRI_GCS"

// *** IMPORTANT: Replace with your actual Personal Access Token ***
// Generate at: GitHub > Settings > Developer settings > Personal access tokens
#define FWD_UPDATE_GITHUB_TOKEN  "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"

// API URL (auto-constructed from owner/repo)
#define FWD_UPDATE_API_URL       "https://api.github.com/repos/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases/latest"

// Web URL for fallback download page
#define FWD_UPDATE_WEB_URL       "https://github.com/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases"
