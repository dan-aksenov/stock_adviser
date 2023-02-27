#!/bin/bash

REPO_ROOT="`dirname \"$0\"`"

rm -rf $REPO_ROOT/venv
python3 -m venv $REPO_ROOT/venv

. $REPO_ROOT/venv/bin/activate

echo "Установка python-зависимости"
# python3 -m pip install $PIP_REPO_PARAMS $PIP_TRUSTED_HOSTS --upgrade certifi
python3 -m pip install $PIP_REPO_PARAMS --upgrade pip
# pip3 install $PIP_REPO_PARAMS --upgrade setuptools wheel
pip3 install -r $REPO_ROOT/requirements.txt --force
