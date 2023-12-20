#!/bin/bash

# Define the content of the pre-commit hook
PRE_COMMIT_HOOK_CONTENT="#!/bin/bash

# Debugging: Print a message to indicate that the hook is starting
echo \"pre-commit hook script started\"

# Define sensitive keywords or patterns to search for
SENSITIVE_PATTERNS=(\"api\" \"pass\")

# Initialize a flag to track if sensitive data is found
SENSITIVE_DATA_FOUND=false

# Debugging: Print the list of files to be checked
echo \"Files to be checked:\"
git diff-index --cached --name-only HEAD -- | cat

# Iterate through the files to be committed
for file in \$(git diff-index --cached --name-only HEAD --); do
  # Debugging: Print the name of the current file being checked
  echo \"Checking file: \$file\"

  for pattern in \"\${SENSITIVE_PATTERNS[@]}\"; do
    if grep -E -qi \"\$pattern\" \"\$file\"; then
      echo \"WARNING: Sensitive data found in \$file\"
      SENSITIVE_DATA_FOUND=true
      break 2  # Exit both loops if sensitive data is found
    fi
  done
done

# Debugging: Print a message indicating that the hook is completed
echo \"pre-commit hook script completed\"

# Check if sensitive data was found and provide an appropriate message
if [ \"\$SENSITIVE_DATA_FOUND\" = true ]; then
  echo \"Security check failed: Sensitive data found\"
  exit 1  # Prevent the commit
else
  # Display a green checkmark for a successful security check
  echo -e \"\\e[32m✅ Security check passed: No sensitive data found\\e[0m\"
fi
"

# Path to the pre-commit hook file
PRE_COMMIT_HOOK_PATH=".git/hooks/pre-commit"

# Check if the pre-commit hook file already exists
if [ -f "$PRE_COMMIT_HOOK_PATH" ]; then
  # If it exists, prompt the user for confirmation to overwrite
  read -p "A pre-commit hook already exists. Do you want to overwrite it? (y/n): " overwrite
  if [ "$overwrite" != "y" ]; then
    echo "Setup canceled."
    exit 0
  fi
fi

# Create or overwrite the pre-commit hook file
echo "$PRE_COMMIT_HOOK_CONTENT" > "$PRE_COMMIT_HOOK_PATH"
chmod +x "$PRE_COMMIT_HOOK_PATH"

echo "Pre-commit hook script has been set up in $PRE_COMMIT_HOOK_PATH."
echo "Make sure to customize the script further if needed."
