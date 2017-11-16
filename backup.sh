#!/bin/sh

set -e
clear

# ASK INFO
echo "---------------------------------------------------------------------"
echo "                  WordPress.org to GitHub BACKUP                     "
echo "---------------------------------------------------------------------"
read -p "Enter the ROOT PATH where the plugin will be backed up to: " ROOT_PATH

if [[ -d $ROOT_PATH ]]; then
	echo "---------------------------------------------------------------------"
	echo "New ROOT PATH has been set."
	cd $ROOT_PATH
elif [[ -f $ROOT_PATH ]]; then
	echo "---------------------------------------------------------------------"
	read -p "$ROOT_PATH is a file. Please enter a ROOT PATH: " ROOT_PATH
fi;

echo "---------------------------------------------------------------------"
read -p "Enter the WordPress plugin slug: " SVN_REPO_SLUG
clear

echo "---------------------------------------------------------------------"
echo "Version of Plugin to Backup. Leave blank to backup everything."
echo "---------------------------------------------------------------------"
echo " - assets"
echo " - trunk"
echo " - e.g. 1.0.0 or v1.0.0 for tags."
echo "---------------------------------------------------------------------"
echo "Do NOT put tags/ in front of the version."
echo "---------------------------------------------------------------------"
read -p "Enter Version: " VERSION

# If version left blank then set to save all. [trunk, tags and assets folders].
if [[ -z ${VERSION} ]]; then
	VERSION=all
	clear
fi;

SVN_REPO_URL="https://plugins.svn.wordpress.org"

# Set WordPress.org Plugin SVN URL
if [[ ${VERSION} == "all" ]]; then
	SVN_REPO=$SVN_REPO_URL"/"$SVN_REPO_SLUG"/"
elif [[ ${VERSION} == "trunk" ]]; then
	SVN_REPO=$SVN_REPO_URL"/"$SVN_REPO_SLUG"/trunk/"
elif [[ ${VERSION} == "assets" ]]; then
	SVN_REPO=$SVN_REPO_URL"/"$SVN_REPO_SLUG"/assets/"
else
	SVN_REPO=$SVN_REPO_URL"/"$SVN_REPO_SLUG"/tags/"$VERSION"/"
fi;

# Set temporary SVN folder for WordPress backup.
TEMP_SVN_REPO=${SVN_REPO_SLUG}"-svn-"${VERSION}

# Delete old SVN cache just incase it was not cleaned before after the last backup.
rm -Rf $ROOT_PATH$TEMP_SVN_REPO

# CHECKOUT SVN DIR IF NOT EXISTS
if [[ ! -d $TEMP_SVN_REPO ]]; then
	echo "---------------------------------------------------------------------"
	echo "Downloading plugin from SVN repository. Please wait..."
	svn checkout $SVN_REPO $TEMP_SVN_REPO || { echo "Unable to checkout repository."; exit 1; }
	echo "---------------------------------------------------------------------"
fi;

# MOVE INTO SVN DIR
cd $ROOT_PATH$TEMP_SVN_REPO

read -p "Enter your GitHub username: " GITHUB_USER
echo "---------------------------------------------------------------------"
read -p "Enter the repository slug: " GITHUB_REPO_NAME
clear

echo "---------------------------------------------------------------------"
echo "Is the line secure?"
echo "---------------------------------------------------------------------"
echo " - y for SSH"
echo " - n for HTTPS"
read -p "" SECURE_LINE

# Set GitHub Repository URL
if [[ ${SECURE_LINE} = "y" ]]; then
	GIT_REPO="git@github.com:"${GITHUB_USER}"/"${GITHUB_REPO_NAME}".git"
else
	GIT_REPO="https://github.com/"${GITHUB_USER}"/"${GITHUB_REPO_NAME}".git"
fi;

# Is this a new repository?
echo "---------------------------------------------------------------------"
echo "Is this a new repository?"
echo "---------------------------------------------------------------------"
echo " - y for new repository."
echo " - n for repository in use."
read -p "" NEW_REPO

if [[ -z ${NEW_REPO} ]] | [[ ${NEW_REPO} != "y" ]] | [[ ${NEW_REPO} != "n" ]]; then
	clear
	echo "---------------------------------------------------------------------"
	echo "Unable to regonize command. Please restart program and try again."
	echo "---------------------------------------------------------------------"
	exit 1;
fi;

# Initialize folder for GitHub just incase.
git init

if [[ ${NEW_REPO} == "y" ]]; then
	echo "---------------------------------------------------------------------"
	echo "New repository initialized."
	echo "---------------------------------------------------------------------"

	git remote add origin ${GIT_REPO}
fi;

clear

# Find remote
if [[ ${NEW_REPO} == "n" ]]; then
	echo "---------------------------------------------------------------------"
	read -p "Which remote are we backing up to? Default is 'origin'" ORIGIN
	echo "---------------------------------------------------------------------"

	# IF REMOTE WAS LEFT EMPTY THEN FETCH ORIGIN BY DEFAULT
	if [[ -z ${ORIGIN} ]]; then
		# Set ORIGIN as origin if left blank
		ORIGIN=origin
	fi;

	# Check that GIT has configured the remote. If not then set it.
	if git remote | grep ${ORIGIN} > /dev/null; then
		git fetch ${ORIGIN}
	else
		# Set GIT repository URL.
		git remote add ${ORIGIN} ${GIT_REPO}

		# Makes sure that the upstream for the branch is set.
		git push --set-upstream ${ORIGIN} master

		# Fetch repository.
		git fetch ${ORIGIN}
	fi;

	# Find branch
	echo "Which branch are we backing up to?"
	git branch -r || { echo "Unable to list branches."; exit 1; }
	echo "---------------------------------------------------------------------"
	read -p ${ORIGIN}"/"${BRANCH}

	# Makes sure that the upstream for the branch is set.
	git push --set-upstream ${ORIGIN} ${BRANCH}

	# First make sure the repository is up to date if the repository is not new.
	echo "Making sure the GIT repository is up to date first. Please wait..."
	git pull ${ORIGIN} ${BRANCH}

	clear

	# Switch Branch
	echo "Switching to branch."
	git checkout ${BRANCH} || { echo "Unable to checkout branch."; exit 1; }
	clear
fi;

# Commit Message Prompt
echo "---------------------------------------------------------------------"
read -p "Enter Commit Message:" COMMIT_MSG
clear

# Add all files to the repository and commit them.
git add *
git commit -m "${COMMIT_MSG}"

echo "---------------------------------------------------------------------"
echo "Saving plugin to GitHub. Please wait..."

if [[ ${NEW_REPO} == "y" ]]; then
	git push -u origin master
else
	# Now upload the commit to the branch.
	git push -u ${ORIGIN} ${BRANCH}
fi;

echo "---------------------------------------------------------------------"
read -p "Press [ENTER] to start cleaning up."
clear

# REMOVE THE TEMP DIRS
echo "---------------------------------------------------------------------"
echo "Cleaning Up. Give me a sec..."
cd "../"
rm -Rf $ROOT_PATH$TEMP_SVN_REPO

echo ""
echo "OK!"
echo ""

# DONE
echo "Backup Done. :)"
echo ""
read -p "Press [ENTER] to close program."

clear

exit 1;
