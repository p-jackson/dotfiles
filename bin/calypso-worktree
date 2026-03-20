#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! inquire = "0.7"
//! clap = { version = "4.5", features = ["derive"] }
//! regex = "1"
//! ```

use clap::{Parser, Subcommand};
use regex::Regex;
use inquire::{InquireError, Select, Text};
use std::fs;
use std::path::PathBuf;
use std::process::{exit, Command};

#[derive(Parser)]
#[command(name = "calypso-worktree")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// New branch from trunk
    Trunk { branch_name: String },
    /// Stack new branch on current branch
    Stack { branch_name: String },
    /// Checkout PR by number
    Pr { pr_number: String },
}

fn main() {
    let home = std::env::var("HOME").unwrap();
    let container_path = PathBuf::from(&home).join("dev").join("wp-calypso");
    let calypso_root = container_path.join("trunk");

    let cli = Cli::parse();

    enum Mode {
        Trunk(String),
        Stack(String),
        Pr(String),
    }

    let mode = match cli.command {
        Some(Commands::Trunk { branch_name }) => Mode::Trunk(branch_name),
        Some(Commands::Stack { branch_name }) => Mode::Stack(branch_name),
        Some(Commands::Pr { pr_number }) => Mode::Pr(pr_number),
        None => {
            // Interactive mode
            let options = vec![
                "New branch from trunk",
                "Stack on current branch",
                "Checkout PR by number (or PR URL)",
            ];

            let selection = match Select::new("How to create branch?", options)
                .with_starting_cursor(0)
                .prompt()
            {
                Ok(s) => s,
                Err(InquireError::OperationInterrupted) => exit(0),
                Err(e) => {
                    eprintln!("Error: {}", e);
                    exit(1);
                }
            };

            match selection {
                "New branch from trunk" => {
                    let name = match Text::new("Branch name:").prompt() {
                        Ok(value) => value,
                        Err(InquireError::OperationInterrupted) => exit(0),
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            exit(1);
                        }
                    };
                    Mode::Trunk(name)
                }
                "Stack on current branch" => {
                    let name = match Text::new("Branch name:").prompt() {
                        Ok(value) => value,
                        Err(InquireError::OperationInterrupted) => exit(0),
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            exit(1);
                        }
                    };
                    Mode::Stack(name)
                }
                "Checkout PR by number (or PR URL)" => {
                    let pr_num = match Text::new("PR number:").prompt() {
                        Ok(value) => value,
                        Err(InquireError::OperationInterrupted) => exit(0),
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            exit(1);
                        }
                    };
                    Mode::Pr(pr_num)
                }
                _ => unreachable!(),
            }
        }
    };

    // Extract branch name early for the "trunk" guard
    let branch_name_for_guard = match &mode {
        Mode::Trunk(b) | Mode::Stack(b) => Some(b.as_str()),
        Mode::Pr(_) => None, // PR branch name not known yet
    };
    if let Some(name) = branch_name_for_guard {
        if name == "trunk" {
            eprintln!("Cannot use 'trunk' as a worktree branch name (reserved for main checkout)");
            exit(1);
        }
    }

    let (branch_name, worktree_path) = match &mode {
        Mode::Trunk(branch_name) => {
            let worktree_path = container_path.join(branch_name);

            let status = Command::new("git")
                .args([
                    "-C",
                    calypso_root.to_str().unwrap(),
                    "worktree",
                    "add",
                    "-b",
                    branch_name,
                    worktree_path.to_str().unwrap(),
                    "trunk",
                ])
                .status()
                .expect("Failed to create worktree");

            if !status.success() {
                eprintln!("Failed to create worktree from trunk");
                exit(1);
            }
            (branch_name.clone(), worktree_path)
        }
        Mode::Stack(branch_name) => {
            let worktree_path = container_path.join(branch_name);

            let status = Command::new("git")
                .args([
                    "worktree",
                    "add",
                    "-b",
                    branch_name,
                    worktree_path.to_str().unwrap(),
                    "HEAD",
                ])
                .status()
                .expect("Failed to create worktree");

            if !status.success() {
                eprintln!("Failed to create stacked worktree");
                exit(1);
            }
            (branch_name.clone(), worktree_path)
        }
        Mode::Pr(pr_input) => {
            // Extract numeric PR number (input may be a URL like .../pull/12345/changes)
            let pr_num = if pr_input.parse::<u64>().is_ok() {
                pr_input.clone()
            } else {
                let re = Regex::new(r"/pull/(\d+)").unwrap();
                match re.captures(&pr_input) {
                    Some(caps) => caps[1].to_string(),
                    None => {
                        eprintln!("Could not extract PR number from: {}", pr_input);
                        exit(1);
                    }
                }
            };

            // Fetch PR and get branch name (gh handles both URLs and numbers)
            let output = Command::new("gh")
                .args([
                    "pr",
                    "view",
                    &pr_input,
                    "--json",
                    "headRefName",
                    "-q",
                    ".headRefName",
                ])
                .current_dir(&calypso_root)
                .output()
                .expect("Failed to get PR branch name");

            if !output.status.success() {
                eprintln!("Failed to fetch PR info");
                exit(1);
            }

            let branch_name = String::from_utf8_lossy(&output.stdout).trim().to_string();

            if branch_name == "trunk" {
                eprintln!("Cannot use 'trunk' as a worktree branch name (reserved for main checkout)");
                exit(1);
            }

            let worktree_path = container_path.join(&branch_name);

            // Fetch PR directly without checkout
            let status = Command::new("git")
                .args([
                    "-C",
                    calypso_root.to_str().unwrap(),
                    "fetch",
                    "origin",
                    &format!("pull/{}/head:{}", pr_num, branch_name),
                ])
                .status()
                .expect("Failed to fetch PR");

            if !status.success() {
                eprintln!("Failed to fetch PR");
                exit(1);
            }

            // Create worktree from fetched branch
            let status = Command::new("git")
                .args([
                    "-C",
                    calypso_root.to_str().unwrap(),
                    "worktree",
                    "add",
                    worktree_path.to_str().unwrap(),
                    &branch_name,
                ])
                .status()
                .expect("Failed to create worktree");

            if !status.success() {
                eprintln!("Failed to create worktree for PR");
                exit(1);
            }
            (branch_name, worktree_path)
        }
    };

    // Copy Claude settings
    let src_settings = calypso_root.join(".claude").join("settings.local.json");
    let dst_settings_dir = worktree_path.join(".claude");
    let dst_settings = dst_settings_dir.join("settings.local.json");

    if src_settings.exists() {
        fs::create_dir_all(&dst_settings_dir).expect("Failed to create .claude dir");
        fs::copy(&src_settings, &dst_settings).expect("Failed to copy Claude settings");
    }

    // Copy CLAUDE.local.md
    let src_claude_local = calypso_root.join("CLAUDE.local.md");
    if src_claude_local.exists() {
        fs::copy(&src_claude_local, &worktree_path.join("CLAUDE.local.md"))
            .expect("Failed to copy CLAUDE.local.md");
    }

    // Copy e2e secrets
    let src_secrets = calypso_root
        .join("packages/calypso-e2e/src/secrets/decrypted-secrets.json");
    let dst_secrets_dir = worktree_path
        .join("packages/calypso-e2e/src/secrets");
    let dst_secrets = dst_secrets_dir.join("decrypted-secrets.json");

    if src_secrets.exists() {
        fs::create_dir_all(&dst_secrets_dir).expect("Failed to create secrets dir");
        fs::copy(&src_secrets, &dst_secrets).expect("Failed to copy e2e secrets");
    }

    // Create tmux session
    let session_name = branch_name.replace("/", "-");

    Command::new("tmux")
        .args([
            "new-session",
            "-d",
            "-s",
            &session_name,
            "-c",
            worktree_path.to_str().unwrap(),
        ])
        .status()
        .expect("Failed to create tmux session");

    // Create background window and run yarn
    Command::new("tmux")
        .args([
            "new-window",
            "-d",
            "-t",
            &format!("{}:1", session_name),
            "-c",
            worktree_path.to_str().unwrap(),
        ])
        .status()
        .expect("Failed to create background window");

    Command::new("tmux")
        .args([
            "send-keys",
            "-t",
            &format!("{}:1", session_name),
            "yarn",
            "Enter",
        ])
        .status()
        .expect("Failed to send yarn command");

    // Switch to session (use switch-client if inside tmux, attach-session otherwise)
    let inside_tmux = std::env::var("TMUX").is_ok();

    if inside_tmux {
        Command::new("tmux")
            .args(["switch-client", "-t", &session_name])
            .status()
            .expect("Failed to switch to tmux session");
    } else {
        Command::new("tmux")
            .args(["attach-session", "-t", &session_name])
            .status()
            .expect("Failed to attach to tmux session");
    }
}
