# Before running this script, set
# export MODEL_NAME="..."
# export MODEL_ORG="..."

# 1. Successful attempt at copying a huggingface repo (not a fork in the git sense)
pip install huggingface_hub
huggingface-cli login
huggingface-cli repo create ${MODEL_NAME} --organization DataikuNLP
git lfs install
git clone https://huggingface.co/DataikuNLP/${MODEL_NAME}
mkdir -p tmp_original_model && cd tmp_original_model
git clone https://huggingface.co/${MODEL_ORG}/${MODEL_NAME}
rsync -vahP --delete-before --exclude=".git/" ${MODEL_NAME}/ ../${MODEL_NAME}
cd ../${MODEL_NAME}
# You may want to manually modify the README.md to include something like
# **This model is a copy of [this model repository](TODO) from sentence-transformers at the specific commit `TODO`.**
git add . && git commit -m "copy of original repo" && git push && cd ..
# Repeat for another model

# 2. Failed attempt at forking a huggingface repo - DOES NOT WORK
# Issue open with huggingface on https://discuss.huggingface.co/t/how-to-fork-in-the-git-sense-a-model-repository/9663
pip install huggingface_hub
huggingface-cli login
huggingface-cli repo create ${MODEL_NAME} --organization DataikuNLP
git lfs install --skip-smudge
git clone https://huggingface.co/DataikuNLP/${MODEL_NAME}
cd ${MODEL_NAME}
git remote add upstream https://huggingface.co/${MODEL_ORG}/${MODEL_NAME}
git fetch upstream
git rebase upstream/main
git push --force-with-lease
