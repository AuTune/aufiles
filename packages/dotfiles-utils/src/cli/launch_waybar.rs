use dotfiles_utils::{full_path, json, monitor::Monitor, nixinfo::NixInfo, WAYBAR_CLASS};
use execute::Execute;

fn main() {
    execute::command_args!("killall", "-q", WAYBAR_CLASS)
        .execute()
        .expect("failed to kill waybar");

    // add / remove persistent workspaces config to waybar config before launching
    let config_path = full_path("~/.config/waybar/config");
    let config_path = config_path
        .to_str()
        .expect("could not convert config path to str");

    if cfg!(feature = "hyprland") {
        let mut cfg: serde_json::Value = json::load(config_path);

        if NixInfo::before().persistent_workspaces {
            let rearranged_workspaces = Monitor::rearranged_workspaces();

            cfg["hyprland/workspaces"]["persistent-workspaces"] =
                serde_json::to_value(rearranged_workspaces).expect("failed to convert to json");
        } else {
            let hyprland_workspaces = cfg["hyprland/workspaces"]
                .as_object_mut()
                .expect("invalid hyprland workspaces");
            hyprland_workspaces.remove("persistent-workspaces");

            cfg["hyprland/workspaces"] =
                serde_json::to_value(hyprland_workspaces).expect("failed to convert to json");
        }

        // write waybar_config back to waybar_config_file as json
        json::write(config_path, &cfg);
    }

    // open waybar in the background
    execute::command!("waybar")
        .execute()
        .expect("failed to execute waybar");
}
