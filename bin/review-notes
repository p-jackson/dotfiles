#!/usr/bin/env rust-script

use std::fs;
use std::path::Path;
use std::process;

fn main() {
    let notes_path = std::env::var("NOTES_PATH")
        .expect("NOTES_PATH env var is required (should be defined in zshrc)");

    if let Some(ok_idx) = std::env::args().position(|arg| arg == "--ok") {
        let reviewed_note_path = std::env::args()
            .nth(ok_idx + 1)
            .expect("The --ok flag should be followed by the path to a note");

        let reviewed_note_name = Path::new(&reviewed_note_path)
            .file_name()
            .expect("Invalid note path");

        let new_note_path = Path::new(&notes_path).join("0-zk").join(reviewed_note_name);

        let exists = new_note_path.try_exists();
        if exists.is_err() || exists.unwrap() == true {
            eprintln!("Refusing to overwrite note that already exists");
            process::exit(1);
        }

        fs::rename(reviewed_note_path, new_note_path).expect("Failed to move the note file");
    } else {
        eprintln!("Missing command line flag to say what to do with note e.g. use --ok");
        process::exit(1);
    }
}
