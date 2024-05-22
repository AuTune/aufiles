# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  hyprlock = {
    pname = "hyprlock";
    version = "972c1c27e6b057e5e891b6ae9f5b2c83bac1e087";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprlock";
      rev = "972c1c27e6b057e5e891b6ae9f5b2c83bac1e087";
      fetchSubmodules = false;
      sha256 = "sha256-5j/GfBVkgqGTlEA7s/6CBn0pKK6ohXQi38lkKeno/mA=";
    };
    date = "2024-05-23";
  };
  mpv-dynamic-crop = {
    pname = "mpv-dynamic-crop";
    version = "c79a46ba03631eb2a9b4f598aab0b723f03fc531";
    src = fetchFromGitHub {
      owner = "Ashyni";
      repo = "mpv-scripts";
      rev = "c79a46ba03631eb2a9b4f598aab0b723f03fc531";
      fetchSubmodules = false;
      sha256 = "sha256-W4Dj2tyJHeHLqAndrzllKs4iwMe3Tu8rfzEGBHuke6s=";
    };
    date = "2023-12-22";
  };
  path-of-building = {
    pname = "path-of-building";
    version = "v2.42.0";
    src = fetchFromGitHub {
      owner = "PathOfBuildingCommunity";
      repo = "PathOfBuilding";
      rev = "v2.42.0";
      fetchSubmodules = false;
      sha256 = "sha256-OxAyB+tMszQktGvxlGL/kc+Wt0iInFYY0qHNjK6EnSg=";
    };
  };
  swww = {
    pname = "swww";
    version = "ebbbe01fbce61176a0c27530163686703f15ae16";
    src = fetchFromGitHub {
      owner = "LGFae";
      repo = "swww";
      rev = "ebbbe01fbce61176a0c27530163686703f15ae16";
      fetchSubmodules = false;
      sha256 = "sha256-OlwleCDoyE+TwNLRn9Z5+EI6x5lnHpxjZricatZsY08=";
    };
    date = "2024-05-23";
  };
  wallust = {
    pname = "wallust";
    version = "6ab659f5fe74988d029a9733cf4f1aa1a3d79952";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "6ab659f5fe74988d029a9733cf4f1aa1a3d79952";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-waJpftMvIRKno0SSFLm4Ti1WtsNnDcvm80lyH/lLJVU=";
    };
    date = "2024-05-13";
  };
}
