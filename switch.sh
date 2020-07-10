#!/usr/bin/env bash

# by default I want "switch" to be my entire system state, both home-manager and my system level nix configuration
# I could change my mind on that, but we'll see. That's why I put the m in different scripts.

# TODO if we aren't on nixos, only switch home-manager

# if we are on nixos, default to switching nixos and home-manager
exec switch_nixos_and_home_manager.sh


