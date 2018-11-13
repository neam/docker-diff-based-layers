#!/usr/bin/env bash

# Use rsync to figure out what changes are necessary to go from old image contents to new
echo "List of changes necessary to go from old image contents to new: "
rsync -a -x --human-readable --delete-after --checksum --dry-run --itemize-changes --exclude .docker-image-diff "$RESTRICT_DIFF_TO_PATH/" "rsync://rsync@old/root$RESTRICT_DIFF_TO_PATH/" | tee $OUT/changes.rsync.log

# Add files to add to a tar archive
cat $OUT/changes.rsync.log | grep  -E '^<f|^cL|^hf' | while read -a cols; do echo "$RESTRICT_DIFF_TO_PATH/"${cols[@]:1}; done > $OUT/files-to-add_2.list

# soft links (^cL in the grep above) have -> in the list which must be removed.  Hard links ^hf have =>
cat $OUT/files-to-add_2.list | grep -oP '^\K.*?(?= ->| =>|$)' > $OUT/files-to-add.list
tar -C / -cf $OUT/files-to-add.tar -T $OUT/files-to-add.list 2>&1

# Add files to remove to a list
cat $OUT/changes.rsync.log | grep '^*deleting' | grep -v 'tmp\/\.rsyncd\.conf' | while read -a cols; do echo "$RESTRICT_DIFF_TO_PATH/"${cols[@]:1}; done > $OUT/files-to-remove.list

# Informational output
echo
echo "Number of files to add: "
wc $OUT/files-to-add.list
echo
echo "Number of files to remove: "
wc $OUT/files-to-remove.list
echo
echo "Changes not accounted for: "
cat $OUT/changes.rsync.log | grep -v -E '^<f|^cL|^hf'  | grep -v '^*deleting'
echo
echo "Press CTRL-C to continue"
