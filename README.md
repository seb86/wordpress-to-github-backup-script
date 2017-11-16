# WordPress.org to GitHub Backup Script
> I want to make it clear that this script is a work in progress and is not yet finished. If you want to contribute to the project then by all means fork it and send a push request.

If you currently or previously use to push your WordPress plugin directly to the WordPress.org SVN first then this backup script might come in handy.

This script is dummy proof. No need to configure anything. Just run the script and follow the instructions as you go along.

## Features
* Supports HTTPS and SSH connections.
* Specify the SVN folder to backup to a GitHub repository.

## What does the script do?
It simply allows you to download a copy of your entire SVN repository and upload it to a GitHub repository.

As you run the script it will asks questions at certain points to setup the process of the script such as the ROOT Path where the script will temporarily store your plugin, WordPress.org plugin slug, SVN location, GitHub username, GIT repository slug etc.

> When asked for the version, just press enter for the entire SVN repository. Otherwise use "trunk", "assets" or the tag name of the version you want.

To use the script you must:

1. Already have a WordPress.org SVN repository setup for your plugin.
2. Already have a repository on GitHub new or already in use.
3. Have both GIT and SVN setup on your machine and available from the command line.

## Getting Started

All you have to do is download the script backup.sh from this repository and place it in a location of your choosing. Can be run from any location.

## Usage

1. Open up terminal and cd to the directory containing the script.
2. Run: ```sh backup.sh```
3. Follow the prompts.

## Final Notes

- Downloading from WordPress.org can take a while so be patient.
- I have tested this on Mac only.
- Use at your own risk of course :smile:

### Support Sébastien's Open Source Projects!
If you'd like me to keep producing free and open source software or if you use this script and find it useful then please consider [paying for an hour](https://www.paypal.me/CodeBreaker/100eur) of my time. I'll spend two hours on open source for each contribution.

You can find more of my Free and Open Source scripts on [GitHub](https://github.com/seb86)
