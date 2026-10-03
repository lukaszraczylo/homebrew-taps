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
BREWFILE_TEMP="${DOCS_DIR}/brewfile_temp.txt"

# Per-cask metadata: category label and optional docs site
get_category() {
  case "$1" in
    kportal) echo "Kubernetes" ;;
    lolcathost) echo "Hosts" ;;
    semver-generator) echo "Git" ;;
    harness-sync) echo "LLM" ;;
    readitall) echo "MCP" ;;
    mcp-filepuff) echo "MCP" ;;
    *) echo "CLI" ;;
  esac
}

get_docs_url() {
  case "$1" in
    kportal) echo "https://kportal.raczylo.com" ;;
    lolcathost) echo "https://lolcathost.raczylo.com" ;;
    *) echo "" ;;
  esac
}

# Cask name differs from the GitHub repository name for some projects
get_repo() {
  case "$1" in
    readitall) echo "mcp-readitall" ;;
    mcp-filepuff) echo "filepuff-mcp" ;;
    *) echo "$1" ;;
  esac
}

html_escape() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  echo "${s}"
}

generate_cask_card() {
  local name="$1"
  local version="$2"
  local desc
  desc=$(html_escape "$3")

  local category
  category=$(get_category "${name}")
  local docs_url
  docs_url=$(get_docs_url "${name}")
  local repo
  repo=$(get_repo "${name}")
  local github_url="https://github.com/lukaszraczylo/${repo}"

  local links_html=""
  if [[ -n "${docs_url}" ]]
  then
    links_html="<a href=\"${docs_url}\">Docs</a>
                                "
  fi
  links_html="${links_html}<a href=\"${github_url}\">GitHub</a>"

  cat <<CARD_EOF
                    <!-- ${name} -->
                    <li class="project">
                        <div class="project-head">
                            <h3>${name}</h3>
                            <span class="meta">v${version} &middot; ${category}</span>
                            <span class="project-links">
                                ${links_html}
                            </span>
                        </div>
                        <p>${desc}</p>
                        <div class="cmd">
                            <pre><code>brew install --cask lukaszraczylo/taps/${name}</code></pre>
                            <button class="copy-btn" type="button" onclick="copyCode(this)">Copy</button>
                        </div>
                    </li>

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
: >"${BREWFILE_TEMP}"

for cask_file in "${CASKS_DIR}"/*.rb
do
  if [[ -f "${cask_file}" ]]
  then
    name=$(basename "${cask_file}" .rb)
    version=$(grep -m1 'version "' "${cask_file}" | sed 's/.*version "\([^"]*\)".*/\1/' 2>/dev/null || echo "latest")
    desc=$(grep -m1 'desc "' "${cask_file}" | sed 's/.*desc "\([^"]*\)".*/\1/' 2>/dev/null || echo "A Homebrew cask")

    generate_cask_card "${name}" "${version}" "${desc}" >>"${TEMP_FILE}"
    echo "cask \"${name}\"" >>"${BREWFILE_TEMP}"
  fi
done

# Rebuild index.html: casks between CASKS_* markers, Brewfile lines between BREWFILE_* markers
{
  sed -n '1,/<!-- CASKS_START -->/p' "${INDEX_FILE}"
  cat "${TEMP_FILE}"
  sed -n '/<!-- CASKS_END -->/,$p' "${INDEX_FILE}"
} | awk -v bf="${BREWFILE_TEMP}" '
  /<!-- BREWFILE_START -->/ { print; while ((getline line < bf) > 0) print line; skip = 1; next }
  /<!-- BREWFILE_END -->/ { skip = 0 }
  !skip { print }
' >"${INDEX_FILE}.new"

mv "${INDEX_FILE}.new" "${INDEX_FILE}"
rm -f "${TEMP_FILE}" "${BREWFILE_TEMP}"

echo "Documentation updated successfully!"
