# Introduction

The current README contains info for the instana downstream located at
https://github.com/instana/opentelemetry-ebpf-profiler

## Downstream management

Since the activity on the upstream is frequent, it is good practise to synch with the upstream frequently, best if it is done maximum every 30 or 45 days.
Currently instana doesn't have an automation for the synch.

The synch and the resolution of merge conflicts is done manually.

## Synch with upstream

Follow these steps:

1. Add the upstream's remote to your remotes' list.

`git remote add upstream git@github.com:open-telemetry/opentelemetry-ebpf-profiler.git`

You can verify the remotes' list with the command `git remote -v`.
The result must be:

```
origin  git@github.com:instana/opentelemetry-ebpf-profiler.git (fetch)
origin  git@github.com:instana/opentelemetry-ebpf-profiler.git (push)
upstream        git@github.com:open-telemetry/opentelemetry-ebpf-profiler.git (fetch)
upstream        git@github.com:open-telemetry/opentelemetry-ebpf-profiler.git (push)
```

2. Align your local index with the upstream's remote objects and refs:
`git fetch upstream --prune`
Alternatively refresh your index for all the remotes:
`git fetch --all --prune`

3. Start the synch in a different branch
Checkout the local branch main, with HEAD origin/main:
`git checkout main`
Be sure you have all the recent updates:
`git pull`
Checkout from `main` a new branch where you will work at the merge with the recent changes in the upstream.
Be sure to give to this branch a significant name, such as `synch_<year>_<n>_wip` where <year> is the current year and <n> is the next ordinal number to identify the synch.
The command will be something like
`git checkout -b synch_2025_01_wip`
Now you are ready to merge the upstream's `main` branch into this branch.
Before doing this, be sure to have the following directories ready somewhere else:
 - A local clone of instana's opentelemtry-ebpf-profiler
 - A local clone of the upstream's opentelemtry-ebpf-profiler
In this way you can always browse these directories without touching the current directory or getting confused saving partial merges, if not necessary.
Run this command to start the merge of the upstream's `main` branch into the `synch_<year>_<n>_wip` branch:
`git merge upstream/main`
It is very likely that you will receive a list of conflicts: be sure to copy past this list and save it on an ASCII text file.

4. Solve conflicts
To solve a conflict, open the file with the conflict. The "HEAD" is the content of the downstream `synch_<year>_<n>_wip` branch, the other stream comes from the upstream's `main` branch.
Once you identify what is the correct content of the file, save the file and run
`git add <file>`
When you solve all the conflicts, you are ready to finalize your Merge. If you are not able to solve all the conflicts, go to "partial merges" section.

5. How to finalize your merge
Before doing this, be sure to have the following directory ready somewhere else:
 - A local clone of the upstream's opentelemtry-ebpf-profiler
Execute
`git push`
if it is needed, execute
`git push --force origin synch_2025_01_wip`
Be careful when you format the Merge Message.
Format the first line of the commit message as `Sync from upstream (year-month-day)`
Format the body of the message as a list of commit messages, coming from the upstream. Be sure to mention Author and Co-author, for every commit.
You can view this info executing the following command on the local clone of the upstream's opentelemtry-ebpf-profiler:
`git log --pretty=format:"%an <%ae> %s %nCo-authored-by: %cN <%cE>"`
Explanation of formatting:
```
%an: Author name
%ae: Author email
%s: Commit message
%cN: Co-author name
%cE: Co-author email
```
This format shows the commit hash, author, and commit message, and if there are co-authors, it will display them under "Co-authored-by".

6. Open a PR from the synch branch, for example from `synch_2025_01_wip`.
When manual testing is finished and the PR is approved and merged on `main`, you are ready to create a synch tag.

7. Note down the last commit merged from the upstream in the Synch PR
The merged PR commits can be seen in the GitHub interface in the Conversation or in the Commits section.
Check the commits before your merge commit, and note down its value: it is really important, since this is a code for releasing the software!

8. Create the tag of the latest synch commit.

Attention: you need the value <last-upstream-commit>, calculated in the previous step.
Checkout the local branch main, with HEAD origin/main:
`git checkout main`
Be sure you have all the recent updates:
`git pull`
Create a new tag in the following exact way (otherwise you break our release pipeline):
```
tag-name = synch_<year>_<n> # compose the tag-name carefully
git tag -a <tag-name> -m "Synch <year> number <n> upstream commit <last-upstream-commit>"
git push origin <tag-name>
```

## Merge Binary Files

To resolve the merge conflict by choosing the upstream version for binary files, follow these steps:

1. Checkout the upstream version:

`git checkout --theirs -- path/to/binary/file`

2. Add the resolved files:

`git add path/to/binary/file`

## Partial Merges

When merging from the upstream, there can be so many complicated conflicts in one commit, that you prefer to stop merging and continue later on after checking more indepently how to re-apply the conflicting commit. But the problem with aborting a merge after you solved a few conflicting commits already is that you “lose” the work you did on fixing those. To not lose partial work, you can "Partially rebase your tree".

You have fixed already a few conflicting commits, but then you hit a big conflict and want to stop the merge. To save your rebase progress, you need to just save your current `HEAD`.
So from this very point, create a branch:
```
git branch synch_<year>_<n>_partial
```

## The Patching system

The release pipeline applies patches on top of a tag, this is why is so important to create a tag with the correct name.
To create n patches from the last tag, apply the following command:
```
git format-patch -<n> HEAD
```
You will notice that <n> files are created.
Clone locally the repository https://github.ibm.com/instana/ebpf-profiler-cicd, create a branch checking-out from `main` branch and add the patch file(s) in the directory `patches`, paying attention to:
1. Substitute the hyphens with underscores
2. Simplify the file name
3. Modify the file name to start with a sequential number, respecting the order of the patches already present in the directory `patches`.
4. Reach the pipeline `epbf-profiler-patch-and-build` at
https://cloud.ibm.com/devops/pipelines/tekton/978df0ca-be40-4139-a131-a22bf1bf421b?env_id=ibm:yp:us-south
and modify these environment properties:
`scripts-repo-branch` from `main` to the branch of ebpf-profiler-cd where the new patches were added
`repotag` to the last synch tag
5. Run the manual trigger: if there are no errors, you are ready to release :-)

## Release process

When a new tag is created, and the testing described in the section [The Patching system](#the-patching-system) are successful, you are ready to release.
1. Reach the pipeline `ebpf-profiler-release` at
https://cloud.ibm.com/devops/pipelines/tekton/029fbce8-7b0d-4f68-a04e-69f5e4723ac7?env_id=ibm:yp:us-south
2. Edit the settings of the pipeline, change the variable `artifact-version` with the value of the upstream commit reported in the last tag message.

Example
`git show synch_2025_01`
The initial snipped output is:
```
tag synch_2025_01
Tagger: Teresa Noviello <Teresa.Noviello@ibm.com>
Date:   Tue Mar 18 09:31:54 2025 -0700

Synch 2025 number 1 upstream commit 2698137
```
From te output above, we save can retreave the <last-upstream-commit> as 2698137.
We reach the pipeline `ebpf-profiler-release` at
https://cloud.ibm.com/devops/pipelines/tekton/029fbce8-7b0d-4f68-a04e-69f5e4723ac7?env_id=ibm:yp:us-south
We edit the pipeline environment variable `artifact-version`, setting the value of <last-upstream-commit>, so 2698137.
We save the new environment and run the Manual Trigger.
If no errors are found in the building, we can retrace the upload on Artifactory in the jobs `upload-agent-x86` and `upload-agent-arm64`.
