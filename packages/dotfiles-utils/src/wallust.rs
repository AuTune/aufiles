use crate::{full_path, json, nixinfo::NixInfo, wallpaper::WallInfo, CommandUtf8, WAYBAR_CLASS};
use execute::Execute;
use std::collections::HashMap;

pub const CUSTOM_THEMES: [&str; 6] = [
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "decay-dark",
    "night-owl",
    "tokyo-night",
];

pub fn apply_theme(theme: &str) {
    if CUSTOM_THEMES.contains(&theme) {
        let colorscheme_file = full_path(format!("~/.config/wallust/{theme}.json"));
        execute::command_args!(
            "wallust",
            "cs",
            colorscheme_file.to_str().expect("invalid colorscheme file"),
        )
        .execute()
        .expect("failed to apply colorscheme");
    } else {
        execute::command_args!("wallust", "theme", &theme)
            .execute()
            .expect("failed to apply theme");
    }
}

fn refresh_zathura() {
    if let Some(zathura_pid_raw) = execute::command_args!(
        "dbus-send",
        "--print-reply",
        "--dest=org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus.ListNames",
    )
    .execute_stdout_lines()
    .iter()
    .find(|line| line.contains("org.pwmt.zathura"))
    {
        let zathura_pid = zathura_pid_raw
            .split('"')
            .max_by_key(|s| s.len())
            .expect("could not extract zathura pid");

        // send message to zathura via dbus
        execute::command_args!(
            "dbus-send",
            "--type=method_call",
            &format!("--dest={zathura_pid}"),
            "/org/pwmt/zathura",
            "org.pwmt.zathura.ExecuteCommand",
            "string:source",
        )
        .execute()
        .ok();
    }
}

/// applies the wallust colors to various applications
pub fn apply_colors() {
    let c = if full_path("~/.cache/wallust/nix.json").exists() {
        NixInfo::after().hyprland_colors()
    } else {
        #[derive(serde::Deserialize)]
        struct Colorscheme {
            colors: HashMap<String, String>,
        }

        let cs_path = full_path("~/.config/wallust/catppuccin-mocha.json");
        let cs: Colorscheme = json::load(cs_path);

        (1..16)
            .map(|n| {
                let k = format!("color{n}");
                format!(
                    "rgb({})",
                    cs.colors.get(&k).expect("color not found").replace('#', "")
                )
            })
            .collect()
    };

    if cfg!(feature = "hyprland") {
        // update borders
        execute::command_args!(
            "hyprctl",
            "keyword",
            "general:col.active_border",
            &format!("{} {} 45deg", c[4], c[0]),
        )
        .execute()
        .expect("failed to set active border color");

        execute::command_args!("hyprctl", "keyword", "general:col.inactive_border", &c[0])
            .execute()
            .expect("failed to set inactive border color");

        // pink border for monocle windows
        execute::command_args!(
            "hyprctl",
            "keyword",
            "windowrulev2",
            "bordercolor",
            &format!("{},fullscreen:1", &c[5]),
        )
        .execute()
        .expect("failed to set border color");
        // teal border for floating windows
        execute::command_args!(
            "hyprctl",
            "keyword",
            "windowrulev2",
            "bordercolor",
            &format!("{},floating:1", &c[6]),
        )
        .execute()
        .expect("failed to set floating border color");
        // yellow border for sticky (must be floating) windows
        execute::command_args!(
            "hyprctl",
            "keyword",
            "windowrulev2",
            "bordercolor",
            &format!("{},pinned:1", &c[3]),
        )
        .execute()
        .expect("failed to set sticky border color");
    }

    // refresh zathura
    refresh_zathura();

    // refresh cava
    execute::command!("killall -SIGUSR2 cava").execute().ok();

    // refresh wfetch
    execute::command!("killall -SIGUSR2 .wfetch-wrapped")
        .execute()
        .ok();

    if cfg!(feature = "hyprland") {
        // sleep to prevent waybar race condition
        std::thread::sleep(std::time::Duration::from_secs(1));

        // refresh waybar
        execute::command_args!("killall", "-SIGUSR2", WAYBAR_CLASS)
            .execute()
            .expect("failed to refresh waybar");
    }

    // reload gtk theme
    // reload_gtk()
}

/// runs wallust with options from wallpapers.json
pub fn from_wallpaper(wallpaper_info: &Option<WallInfo>, wallpaper: &str) {
    let mut wallust = execute::command_args!("wallust", "run");

    // normalize the options for wallust
    if let Some(WallInfo {
        wallust: Some(opts),
        ..
    }) = wallpaper_info
    {
        // split opts into flags
        let opts: Vec<&str> = opts.split(' ').map(str::trim).collect();
        wallust.args(opts);
    }

    wallust
        .arg(wallpaper)
        .execute()
        .expect("wallust: failed to set colors from wallpaper");
}
