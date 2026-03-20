#!/usr/bin/env rust-script

use std::env;
use std::process::Command;

fn main() {
    let dry_run = env::args().any(|a| a == "--dry-run" || a == "-n");
    let home = std::env::var("HOME").unwrap();
    let calypso_prefix = format!("{}/dev/wp-calypso", home);

    // Get all panes with their target, command, and path
    let output = Command::new("tmux")
        .args([
            "list-panes",
            "-a",
            "-F",
            "#{session_name}:#{window_index}.#{pane_index}\t#{pane_current_command}\t#{pane_current_path}",
        ])
        .output();

    let output = match output {
        Ok(o) if o.status.success() => o,
        Ok(_) => {
            eprintln!("No tmux server running");
            return;
        }
        Err(e) => {
            eprintln!("Failed to run tmux: {}", e);
            return;
        }
    };

    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut found = false;

    for line in stdout.lines() {
        let parts: Vec<&str> = line.split('\t').collect();
        if parts.len() != 3 {
            continue;
        }

        let target = parts[0];
        let command = parts[1];
        let path = parts[2];

        // Check if this looks like a Calypso dev server
        let is_calypso_path = path.starts_with(&calypso_prefix);
        let is_node_process = command == "node";

        if is_calypso_path && is_node_process {
            found = true;
            if dry_run {
                println!("{}\t{}", target, path);
            } else {
                println!("Stopping {}", path);
                if let Err(e) = Command::new("tmux")
                    .args(["send-keys", "-t", target, "C-c"])
                    .status()
                {
                    eprintln!("Failed to send C-c to {}: {}", target, e);
                }
            }
        }
    }

    if !found {
        println!("No Calypso dev servers found running");
    }
}
