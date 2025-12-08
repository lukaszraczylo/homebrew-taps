#!/usr/bin/env bash
# shellcheck disable=SC2311,SC2312
set -e

# Generate documentation from Casks
# This script parses .rb files in Casks/ and updates docs/index.html

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
CASKS_DIR="${ROOT_DIR}/Casks"
DOCS_DIR="${ROOT_DIR}/docs"
INDEX_FILE="${DOCS_DIR}/index.html"
TEMP_FILE="${DOCS_DIR}/casks_temp.html"

# Get metadata for a cask
get_icon() {
  case "$1" in
    kportal) echo "fa-ship" ;;
    lolcathost) echo "fa-cat" ;;
    semver-generator) echo "fa-code-branch" ;;
    graphql-monitoring-proxy) echo "fa-chart-line" ;;
    *) echo "fa-cube" ;;
  esac
}

get_colors() {
  case "$1" in
    kportal) echo "from-blue-500 to-purple-600" ;;
    lolcathost) echo "from-pink-500 to-purple-600" ;;
    semver-generator) echo "from-emerald-500 to-teal-600" ;;
    graphql-monitoring-proxy) echo "from-rose-500 to-orange-600" ;;
    *) echo "from-gray-500 to-gray-600" ;;
  esac
}

get_tag1() {
  case "$1" in
    kportal) echo "Kubernetes" ;;
    lolcathost) echo "Hosts" ;;
    semver-generator) echo "Git" ;;
    graphql-monitoring-proxy) echo "GraphQL" ;;
    *) echo "CLI" ;;
  esac
}

get_tag1_color() {
  case "$1" in
    kportal) echo "blue" ;;
    lolcathost) echo "pink" ;;
    semver-generator) echo "emerald" ;;
    graphql-monitoring-proxy) echo "rose" ;;
    *) echo "gray" ;;
  esac
}

get_tag2() {
  case "$1" in
    kportal) echo "TUI" ;;
    lolcathost) echo "TUI" ;;
    semver-generator) echo "Versioning" ;;
    graphql-monitoring-proxy) echo "Monitoring" ;;
    *) echo "" ;;
  esac
}

get_tag2_color() {
  case "$1" in
    kportal) echo "purple" ;;
    lolcathost) echo "purple" ;;
    semver-generator) echo "teal" ;;
    graphql-monitoring-proxy) echo "orange" ;;
    *) echo "gray" ;;
  esac
}

get_docs_url() {
  case "$1" in
    kportal) echo "https://kportal.raczylo.com" ;;
    lolcathost) echo "https://lolcathost.raczylo.com" ;;
    graphql-monitoring-proxy) echo "https://graphql-monitoring-proxy.raczylo.com" ;;
    *) echo "" ;;
  esac
}

generate_cask_card() {
  local name="$1"
  local version="$2"
  local desc="$3"

  local icon
  icon=$(get_icon "${name}")
  local colors
  colors=$(get_colors "${name}")
  local tag1
  tag1=$(get_tag1 "${name}")
  local tag1_color
  tag1_color=$(get_tag1_color "${name}")
  local tag2
  tag2=$(get_tag2 "${name}")
  local tag2_color
  tag2_color=$(get_tag2_color "${name}")
  local docs_url
  docs_url=$(get_docs_url "${name}")
  local github_url="https://github.com/lukaszraczylo/${name}"

  local tags_html="<span class=\"px-2 py-1 bg-${tag1_color}-100 dark:bg-${tag1_color}-900/30 text-${tag1_color}-700 dark:text-${tag1_color}-300 rounded text-xs\">${tag1}</span>"
  if [[ -n "${tag2}" ]]
  then
    tags_html="${tags_html}
                            <span class=\"px-2 py-1 bg-${tag2_color}-100 dark:bg-${tag2_color}-900/30 text-${tag2_color}-700 dark:text-${tag2_color}-300 rounded text-xs\">${tag2}</span>"
  fi

  local buttons_html=""
  if [[ -n "${docs_url}" ]]
  then
    buttons_html="<a href=\"${docs_url}\" target=\"_blank\" class=\"flex-1 text-center px-3 py-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg text-sm font-medium transition-colors\">
                                <i class=\"fas fa-book mr-1\"></i>Docs
                            </a>
                            <a href=\"${github_url}\" target=\"_blank\" class=\"flex-1 text-center px-3 py-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg text-sm font-medium transition-colors\">
                                <i class=\"fab fa-github mr-1\"></i>GitHub
                            </a>"
  else
    buttons_html="<a href=\"${github_url}\" target=\"_blank\" class=\"flex-1 text-center px-3 py-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg text-sm font-medium transition-colors\">
                                <i class=\"fab fa-github mr-1\"></i>GitHub
                            </a>"
  fi

  cat <<CARD_EOF
                    <!-- ${name} -->
                    <div class="glass p-6 rounded-xl group hover:shadow-lg transition-all duration-300">
                        <div class="flex items-start gap-4 mb-4">
                            <div class="w-12 h-12 rounded-xl bg-gradient-to-br ${colors} flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform duration-300">
                                <i class="fas ${icon} text-white text-lg"></i>
                            </div>
                            <div class="flex-1">
                                <h3 class="font-bold text-gray-900 dark:text-gray-100 text-lg">${name}</h3>
                                <span class="text-xs text-gray-500 dark:text-gray-400">v${version}</span>
                            </div>
                        </div>
                        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">${desc}</p>
                        <div class="flex flex-wrap gap-2 mb-4">
                            ${tags_html}
                        </div>
                        <div class="flex gap-2">
                            ${buttons_html}
                        </div>
                        <div class="code-block mt-4">
                            <pre class="bg-gray-900 text-gray-100 p-3 pr-16 rounded-lg text-xs overflow-x-auto"><code>brew install --cask lukaszraczylo/taps/${name}</code></pre>
                            <button class="copy-btn" onclick="copyCode(this)" title="Copy to clipboard"><i class="fas fa-copy"></i></button>
                        </div>
                    </div>

CARD_EOF
}

# Main
echo "Generating documentation from Casks..."

if [[ ! -f "${INDEX_FILE}" ]]
then
  echo "Error: ${INDEX_FILE} not found"
  exit 1
fi

# Generate casks HTML to temp file
echo "" >"${TEMP_FILE}"

for cask_file in "${CASKS_DIR}"/*.rb
do
  if [[ -f "${cask_file}" ]]
  then
    name=$(basename "${cask_file}" .rb)
    version=$(grep -m1 'version "' "${cask_file}" | sed 's/.*version "\([^"]*\)".*/\1/' 2>/dev/null || echo "latest")
    desc=$(grep -m1 'desc "' "${cask_file}" | sed 's/.*desc "\([^"]*\)".*/\1/' 2>/dev/null || echo "A Homebrew cask")

    generate_cask_card "${name}" "${version}" "${desc}" >>"${TEMP_FILE}"
  fi
done

# Now rebuild the index.html with the new casks content
# Read and process the file
{
  # Print everything up to and including CASKS_START
  sed -n '1,/<!-- CASKS_START -->/p' "${INDEX_FILE}"
  # Print the generated casks
  cat "${TEMP_FILE}"
  # Print everything from CASKS_END onwards
  sed -n '/<!-- CASKS_END -->/,$p' "${INDEX_FILE}"
} >"${INDEX_FILE}.new"

mv "${INDEX_FILE}.new" "${INDEX_FILE}"
rm -f "${TEMP_FILE}"

echo "Documentation updated successfully!"
