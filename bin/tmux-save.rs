#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! clap = { version = "4.5", features = ["derive"] }
//! ```

use anyhow::{Context, Result};
use clap::Parser;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::Command;

#[derive(Parser)]
#[command(name = "tmux-save", about = "Save tmux session state")]
struct Cli {
    /// Print state to stdout instead of saving
    #[arg(short = 'n', long)]
    dry_run: bool,

    /// Install crontab entry for auto-save every 15min
    #[arg(long)]
    setup_cron: bool,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    if cli.setup_cron {
        return install_cron();
    }

    let sessions = match tmux_output(&["list-sessions", "-F", "#{session_name}"]) {
        Some(s) => s,
        None => {
            eprintln!("No tmux server running");
            return Ok(());
        }
    };

    if cli.dry_run {
        let stdout = std::io::stdout().lock();
        let mut out = std::io::BufWriter::new(stdout);
        write_state(&mut out, &sessions)?;
    } else {
        let home = std::env::var("HOME").context("HOME not set")?;
        let dir = PathBuf::from(&home).join(".local/share/tmux-resurrect");
        fs::create_dir_all(&dir).context("creating save dir")?;
        let path = dir.join("last.txt");
        let mut buf = Vec::new();
        write_state(&mut buf, &sessions)?;
        fs::write(&path, &buf).context("writing save file")?;
        println!("Saved to {}", path.display());
    }

    Ok(())
}

fn tmux_output(args: &[&str]) -> Option<String> {
    let out = Command::new("tmux").args(args).output().ok()?;
    if !out.status.success() {
        return None;
    }
    let s = String::from_utf8_lossy(&out.stdout).trim().to_string();
    if s.is_empty() {
        None
    } else {
        Some(s)
    }
}

fn write_state(out: &mut dyn Write, sessions: &str) -> Result<()> {
    for sess in sessions.lines() {
        writeln!(out, "session\t{}", sess)?;

        let wins = match tmux_output(&[
            "list-windows",
            "-t",
            sess,
            "-F",
            "#{window_index}\t#{window_name}\t#{window_layout}\t#{window_active}",
        ]) {
            Some(s) => s,
            None => continue,
        };

        for win_line in wins.lines() {
            let w: Vec<&str> = win_line.split('\t').collect();
            if w.len() != 4 {
                continue;
            }
            writeln!(
                out,
                "window\t{}\t{}\t{}\t{}\t{}",
                sess, w[0], w[1], w[2], w[3]
            )?;

            let panes = match tmux_output(&[
                "list-panes",
                "-t",
                &format!("{}:{}", sess, w[0]),
                "-F",
                "#{pane_index}\t#{pane_current_path}\t#{pane_current_command}\t#{pane_active}",
            ]) {
                Some(s) => s,
                None => continue,
            };

            for pane_line in panes.lines() {
                let p: Vec<&str> = pane_line.split('\t').collect();
                if p.len() != 4 {
                    continue;
                }
                writeln!(
                    out,
                    "pane\t{}\t{}\t{}\t{}\t{}\t{}",
                    sess, w[0], p[0], p[1], p[2], p[3]
                )?;
            }
        }
    }
    Ok(())
}

fn install_cron() -> Result<()> {
    let home = std::env::var("HOME").context("HOME not set")?;
    let script = PathBuf::from(&home).join("bin/tmux-save.rs");
    let entry = format!("*/15 * * * * {} 2>/dev/null", script.display());

    let existing = Command::new("crontab")
        .arg("-l")
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).to_string())
        .unwrap_or_default();

    if existing.contains("tmux-save.rs") {
        println!("Already installed");
        return Ok(());
    }

    let new_crontab = if existing.trim().is_empty() {
        format!("{}\n", entry)
    } else {
        format!("{}\n{}\n", existing.trim_end(), entry)
    };

    let mut child = Command::new("crontab")
        .arg("-")
        .stdin(std::process::Stdio::piped())
        .spawn()
        .context("running crontab")?;

    child
        .stdin
        .take()
        .expect("stdin was piped")
        .write_all(new_crontab.as_bytes())
        .context("writing to crontab stdin")?;

    child.wait().context("waiting for crontab")?;
    println!("Installed: {}", entry);
    Ok(())
}
