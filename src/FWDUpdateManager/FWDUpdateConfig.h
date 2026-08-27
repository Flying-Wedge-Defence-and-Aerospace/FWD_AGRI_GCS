#pragma once

// GitHub repository configuration for auto-update
#define FWD_UPDATE_GITHUB_OWNER  "Flying-Wedge-Defence-and-Aerospace"
#define FWD_UPDATE_GITHUB_REPO   "FWD_AGRI_GCS"

// PAT token loaded from local config (not committed to repo)
// CI creates this file from secrets before build; locally use FWDUpdateConfig_local.h
#if __has_include("FWDUpdateConfig_local.h")
#include "FWDUpdateConfig_local.h"
#else
#define FWD_UPDATE_GITHUB_TOKEN  ""
#endif

// API URL (auto-constructed from owner/repo)
#define FWD_UPDATE_API_URL       "https://api.github.com/repos/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases/latest"

// Web URL for fallback download page
#define FWD_UPDATE_WEB_URL       "https://github.com/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases"
