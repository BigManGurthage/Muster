# Muster — Group GitHub Guide

Type these into the terminal in VS Code (**Terminal → New Terminal**). They're the same on Mac and Windows.

## Before you start

1. **Make a GitHub account** at [github.com/signup](https://github.com/signup) (free). Send your username to Gurthage so he can add you to the repo.
2. **Install Git.** VS Code needs Git installed to run these commands.
   - **Mac:** in the VS Code terminal type `git --version`. If Git isn't installed, a popup offers to install it. Click **Install**.
   - **Windows:** download it from [git-scm.com/download/win](https://git-scm.com/download/win), click Next through the installer, then restart VS Code.

You don't need to install anything extra for GitHub in VS Code. It asks you to sign in the first time you push.

## First time only

Accept the collaborator invite in your email first, then run:

```bash
git clone https://github.com/BigManGurthage/Muster.git
cd Muster
```

Then open the **Muster** folder in VS Code (**File → Open Folder**).

## Every time you work on it

Before you start, get everyone's latest changes:

```bash
git pull
```

When you've finished and saved your files:

```bash
git add .
git commit -m "what you changed"
git push
```

The first time you push, VS Code will ask you to sign in to GitHub. Click **Allow** and approve it in the browser. You won't need a password after that.

## Other useful commands

| Command | What it does |
| --- | --- |
| `git status` | Shows which files you've changed |
| `git log --oneline` | Shows recent commits |
| `git restore filename.html` | Throws away your unsaved changes to that file |
| `git pull` then `git push` | Fixes "push rejected" — someone pushed before you |
