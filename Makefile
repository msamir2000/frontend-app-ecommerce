requirements:
	npm install

i18n.extract:
    # Pulling display strings from .jsx files into .json files...
	npm run-script i18n_extract

i18n.concat:
    # Gathering JSON messages into one file...
	./src/i18n/i18n-concat.js ./temp/src ./src/i18n/transifex_input.json


# The following make targets are required by our tooling scripts found in:
# - https://github.com/edx/ecommerce-scripts/tree/master/transifex

extract_translations: | requirements i18n.extract i18n.concat

detect_changed_source_translations:
	git diff --exit-code ./src/i18n/transifex_input.json

tx_url1 = https://www.transifex.com/api/2/project/edx-platform/resource/frontend-app-ecommerce/translation/en/strings/
tx_url2 = https://www.transifex.com/api/2/project/edx-platform/resource/frontend-app-ecommerce/source/

# push translations to Transifex, doing magic so we can include the translator comments
# Note: extract_translations is a prereq that our translation script calls separately.
push_translations:
	tx push -s
	# Adding translator comments...
	# Fetching strings from Transifex...
	./node_modules/reactifex/bash_scripts/get_hashed_strings.sh $(tx_url1)
    # Writing out comments to file...
	./src/i18n/i18n-concat.js ./temp/src --comments
    # Adding comments to Transifex...
	./node_modules/reactifex/bash_scripts/put_comments.sh $(tx_url2)

# pull translations from Transifex
pull_translations: ## must be exactly this name for edx tooling support, see ecommerce-scripts/transifex/pull.py
	tx pull -f --mode reviewed --language="ar,fr,es_419,zh_CN"

validate-no-uncommitted-package-lock-changes:
	git diff --exit-code package-lock.json
