# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  hyprcursor = {
    pname = "hyprcursor";
    version = "17ebb7fff097790be80fcc86bb1a6057313d80b4";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprcursor";
      rev = "17ebb7fff097790be80fcc86bb1a6057313d80b4";
      fetchSubmodules = false;
      sha256 = "sha256-2QvWtS0r0Yq2l47e/o6ravQrNI8V+6vnIqEdaoI24Hs=";
    };
    date = "2024-04-08";
  };
  hyprlock = {
    pname = "hyprlock";
    version = "bc87adf9ec997090f15d9b662d6ca2f86e25f264";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprlock";
      rev = "bc87adf9ec997090f15d9b662d6ca2f86e25f264";
      fetchSubmodules = false;
      sha256 = "sha256-rbzVe2WNdHynJrnyJsKOOrV8yuuJ7QIuah3ZHWERSnA=";
    };
    date = "2024-04-08";
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
    version = "3a3596c3b22740086f18ffb6b02aa89ef26a04fe";
    src = fetchFromGitHub {
      owner = "LGFae";
      repo = "swww";
      rev = "3a3596c3b22740086f18ffb6b02aa89ef26a04fe";
      fetchSubmodules = false;
      sha256 = "sha256-PFfXSRTSAffU/4dHVYrqUCAkbN7J6cqX6DJ2s4vT8Rc=";
    };
    date = "2024-04-08";
  };
  wallust = {
    pname = "wallust";
    version = "104d99fcb4ada743d45de76caa48cd899b021601";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "104d99fcb4ada743d45de76caa48cd899b021601";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-gGyxRdv2I/3TQWrTbUjlJGsaRv4SaNE+4Zo9LMWmxk8=";
    };
    date = "2024-03-08";
  };
}
