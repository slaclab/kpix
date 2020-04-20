#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : Release Generation
# ----------------------------------------------------------------------------
# Description:
# Script to generate rogue.zip and cpsw.tar.gz files as well as creating
# a github release with proper release attachments.
# ----------------------------------------------------------------------------
# This file is part of the 'SLAC Firmware Standard Library'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'SLAC Firmware Standard Library', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
# ----------------------------------------------------------------------------

import sys
import os
import argparse
import requests
import zipfile
import io

import github  # PyGithub

# Set the argument parser
parser = argparse.ArgumentParser('Release Download')

# Add arguments
parser.add_argument(
    "--repo",
    type     = str,
    required = True,
    help     = "Github Repo"
)

parser.add_argument(
    "--tag",
    type     = str,
    required = True,
    help     = "Tag to release"
)

# Get the arguments
args = parser.parse_args()

print("\nLogging into github....\n")

token = os.environ.get('GITHUB_TOKEN')

if token is None:
    sys.exit("Failed to get github token from GITHUB_TOKEN environment variable")

gh = github.Github(token)
remRepo = gh.get_repo(args.repo)

try:

    release = remRepo.get_release(args.tag)
    assets = release.get_assets()
    for asset in assets:
        if asset.name == f'rogue_{args.tag}.zip':

            print(f"Downloading and unzipping {asset.name} with id {asset.id}")

            r = requests.get(asset.url, stream=True, headers=dict(Accept='application/octet-stream',
                                                                  Authorization="token " + token))

            zd = zipfile.ZipFile(io.BytesIO(r.content))
            zd.extractall()
except Exception:
    sys.exit(f"Failed to find and download tag {args.tag}")
