#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! clap = { version = "4.5", features = ["derive"] }
//! ```

use anyhow::{Context, Result};
use clap::Parser;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

const SAFE_COMMANDS_TO_RESTORE: &[&str] = &[
    "btop",
    "claude",
    "gh", /* for gh dash */
    "htop",
    "lazydocker",
    "lazygit",
    "less",
    "man",
    "nvim",
    "top",
];

#[derive(Parser)]
#[command(
    name = "tmux-restore",
    about = "Restore tmux sessions from saved state"
)]
struct Cli {
    /// Print tmux commands instead of running them
    #[arg(short = 'n', long)]
    dry_run: bool,
}

#[derive(Debug)]
struct Session {
    name: String,
    windows: Vec<Window>,
}

#[derive(Debug)]
struct Window {
    index: String,
    name: String,
    layout: String,
    active: bool,
    panes: Vec<Pane>,
}

#[derive(Debug)]
struct Pane {
    dir: String,
    command: String,
    active: bool,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    let home = std::env::var("HOME").context("HOME not set")?;
    let path = PathBuf::from(&home).join(".local/share/tmux-resurrect/last.txt");
    let content =
        fs::read_to_string(&path).with_context(|| format!("reading {}", path.display()))?;

    let sessions = parse(&content);
    let mut errors: Vec<String> = Vec::new();

    for sess in &sessions {
        if !cli.dry_run && has_session(&sess.name) {
            println!("Skipping existing session: {}", sess.name);
            continue;
        }
        if cli.dry_run {
            println!("# session: {}", sess.name);
        }

        let mut active_win: Option<&str> = None;

        for (wi, win) in sess.windows.iter().enumerate() {
            if win.active {
                active_win = Some(&win.index);
            }

            if wi == 0 {
                // First window: created by new-session
                let first_dir = win.panes.first().map(|p| p.dir.as_str()).unwrap_or("~");
                if let Err(e) = run_tmux(
                    &["new-session", "-d", "-s", &sess.name, "-c", first_dir],
                    cli.dry_run,
                ) {
                    errors.push(e);
                }
                if let Err(e) = run_tmux(
                    &[
                        "rename-window",
                        "-t",
                        &format!("{}:{}", sess.name, win.index),
                        &win.name,
                    ],
                    cli.dry_run,
                ) {
                    errors.push(e);
                }
            } else {
                let first_dir = win.panes.first().map(|p| p.dir.as_str()).unwrap_or("~");
                if let Err(e) = run_tmux(
                    &[
                        "new-window",
                        "-t",
                        &format!("{}:{}", sess.name, win.index),
                        "-n",
                        &win.name,
                        "-c",
                        first_dir,
                    ],
                    cli.dry_run,
                ) {
                    errors.push(e);
                }
            }

            // Extra panes via split-window (first pane already exists)
            let mut active_pane_idx: Option<usize> = None;
            for (pi, pane) in win.panes.iter().enumerate() {
                if pane.active {
                    active_pane_idx = Some(pi);
                }
                if pi > 0 {
                    if let Err(e) = run_tmux(
                        &[
                            "split-window",
                            "-t",
                            &format!("{}:{}", sess.name, win.index),
                            "-c",
                            &pane.dir,
                        ],
                        cli.dry_run,
                    ) {
                        errors.push(e);
                    }
                }
            }

            // Apply layout after all panes exist
            if let Err(e) = run_tmux(
                &[
                    "select-layout",
                    "-t",
                    &format!("{}:{}", sess.name, win.index),
                    &win.layout,
                ],
                cli.dry_run,
            ) {
                errors.push(e);
            }

            // Restore whitelisted commands
            for (pi, pane) in win.panes.iter().enumerate() {
                if SAFE_COMMANDS_TO_RESTORE.contains(&pane.command.as_str()) {
                    if let Err(e) = run_tmux(
                        &[
                            "send-keys",
                            "-t",
                            &format!("{}:{}.{}", sess.name, win.index, pi),
                            &pane.command,
                            "Enter",
                        ],
                        cli.dry_run,
                    ) {
                        errors.push(e);
                    }
                }
            }

            // Select active pane
            if let Some(idx) = active_pane_idx {
                if let Err(e) = run_tmux(
                    &[
                        "select-pane",
                        "-t",
                        &format!("{}:{}.{}", sess.name, win.index, idx),
                    ],
                    cli.dry_run,
                ) {
                    errors.push(e);
                }
            }
        }

        // Select active window
        if let Some(idx) = active_win {
            if let Err(e) = run_tmux(
                &["select-window", "-t", &format!("{}:{}", sess.name, idx)],
                cli.dry_run,
            ) {
                errors.push(e);
            }
        }
    }

    if !errors.is_empty() {
        eprintln!("\n{} error(s) during restore:", errors.len());
        for e in &errors {
            eprintln!("  {}", e);
        }
        std::process::exit(1);
    }

    if !cli.dry_run && std::env::var("TMUX").is_err() {
        println!("Run `tmux a` to attach");
    }

    Ok(())
}

fn run_tmux(args: &[&str], dry_run: bool) -> Result<(), String> {
    if dry_run {
        println!("tmux {}", args.join(" "));
        return Ok(());
    }
    match Command::new("tmux").args(args).status() {
        Ok(status) if status.success() => Ok(()),
        Ok(status) => Err(format!("tmux {} exited with {}", args.join(" "), status)),
        Err(e) => Err(format!("tmux {} failed: {}", args.join(" "), e)),
    }
}

fn has_session(name: &str) -> bool {
    Command::new("tmux")
        .args(["has-session", "-t", name])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn parse(content: &str) -> Vec<Session> {
    let mut sessions: Vec<Session> = Vec::new();

    for line in content.lines() {
        let parts: Vec<&str> = line.split('\t').collect();
        match parts.first() {
            Some(&"session") if parts.len() >= 2 => {
                sessions.push(Session {
                    name: parts[1].to_string(),
                    windows: Vec::new(),
                });
            }
            Some(&"window") if parts.len() >= 6 => {
                if let Some(sess) = sessions.iter_mut().find(|s| s.name == parts[1]) {
                    sess.windows.push(Window {
                        index: parts[2].to_string(),
                        name: parts[3].to_string(),
                        layout: parts[4].to_string(),
                        active: parts[5] == "1",
                        panes: Vec::new(),
                    });
                }
            }
            Some(&"pane") if parts.len() >= 7 => {
                if let Some(sess) = sessions.iter_mut().find(|s| s.name == parts[1]) {
                    if let Some(win) = sess.windows.iter_mut().find(|w| w.index == parts[2]) {
                        win.panes.push(Pane {
                            dir: parts[4].to_string(),
                            command: parts[5].to_string(),
                            active: parts[6] == "1",
                        });
                    }
                }
            }
            _ => {}
        }
    }

    sessions
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_basic() {
        let input = "session\tdev\n\
                      window\tdev\t0\teditor\t1234,100x50,0,0\t1\n\
                      pane\tdev\t0\t0\t/home/user/code\tnvim\t1\n\
                      pane\tdev\t0\t1\t/home/user\tzsh\t0\n";
        let sessions = parse(input);
        assert_eq!(sessions.len(), 1);
        assert_eq!(sessions[0].name, "dev");
        assert_eq!(sessions[0].windows.len(), 1);
        assert!(sessions[0].windows[0].active);
        assert_eq!(sessions[0].windows[0].panes.len(), 2);
        assert_eq!(sessions[0].windows[0].panes[0].command, "nvim");
        assert!(sessions[0].windows[0].panes[0].active);
        assert!(!sessions[0].windows[0].panes[1].active);
    }

    #[test]
    fn parse_multiple_sessions() {
        let input = "session\tdev\n\
                      window\tdev\t0\tcode\tlayout\t1\n\
                      pane\tdev\t0\t0\t/tmp\tzsh\t1\n\
                      session\tops\n\
                      window\tops\t0\tlogs\tlayout\t0\n\
                      window\tops\t1\tmon\tlayout\t1\n\
                      pane\tops\t0\t0\t/var/log\ttail\t1\n\
                      pane\tops\t1\t0\t/home\thtop\t1\n";
        let sessions = parse(input);
        assert_eq!(sessions.len(), 2);
        assert_eq!(sessions[1].name, "ops");
        assert_eq!(sessions[1].windows.len(), 2);
    }

    #[test]
    fn parse_empty_input() {
        let sessions = parse("");
        assert!(sessions.is_empty());
    }

    #[test]
    fn parse_unknown_line_types_ignored() {
        let input = "session\tdev\n\
                      unknown\tgarbage\n\
                      window\tdev\t0\tsh\tlayout\t1\n";
        let sessions = parse(input);
        assert_eq!(sessions.len(), 1);
        assert_eq!(sessions[0].windows.len(), 1);
    }

    #[test]
    fn parse_malformed_lines_skipped() {
        let input = "session\tdev\n\
                      window\tdev\n\
                      pane\tdev\t0\n\
                      window\tdev\t0\tsh\tlayout\t1\n";
        let sessions = parse(input);
        assert_eq!(sessions.len(), 1);
        assert_eq!(sessions[0].windows.len(), 1);
    }
}
