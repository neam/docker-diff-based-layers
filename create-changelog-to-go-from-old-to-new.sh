#!/usr/bin/env bash

# Use rsync to figure out what changes are necessary to go from old image contents to new
echo "List of changes necessary to go from old image contents to new: "

echo "[root]" > /tmp/.rsyncd.conf;
echo "path = /" >> /tmp/.rsyncd.conf;
echo "read only = false" >> /tmp/.rsyncd.conf;
echo "uid=root" >> /tmp/.rsyncd.conf;
echo "gid=root" >> /tmp/.rsyncd.conf;

echo rsync -a -H -x --human-readable --delete-after --checksum --dry-run --itemize-changes --exclude .docker-image-diff "$RESTRICT_DIFF_TO_PATH/" "rsync://rsync@old/root$RESTRICT_DIFF_TO_PATH/" | tee $OUT/changes.rsync.log

rsync -a -H -x --human-readable --delete-after --checksum --dry-run --itemize-changes --exclude .docker-image-diff "$RESTRICT_DIFF_TO_PATH/" "rsync://rsync@old/root$RESTRICT_DIFF_TO_PATH/" | tee $OUT/changes.rsync.log

# Add files to add to a tar archive
echo "adding to tar "

cat $OUT/changes.rsync.log | grep  -E '^<f|^cL|hf' | while read -a cols; do echo "$RESTRICT_DIFF_TO_PATH/"${cols[@]:1}; done > $OUT/files-to-add_2.list

cat $OUT/files-to-add_2.list | grep -oP '^\K.*?(?= ->| =>|$)' > $OUT/files-to-add.list

pwd
ls -a
cd ..
pwd
ls -a

tar -cf $OUT/files-to-add.tar -T $OUT/files-to-add.list 2>&1
#| grep -v  "Removing leading"
cd /.docker-image-diff/
ls


# Add files to remove to a list
echo "List to delete "
cat $OUT/changes.rsync.log | grep '^*deleting' | while read -a cols; do echo "$RESTRICT_DIFF_TO_PATH/"${cols[@]:1}; done > $OUT/files-to-remove.list

# Informational output
echo
echo "Number of files to add: "
wc $OUT/files-to-add.list
echo
echo "Number of files to remove: "
wc $OUT/files-to-remove.list
echo
echo "Changes not accounted for: "
cat $OUT/changes.rsync.log | grep -v -E '^<f|^cL|hf'  | grep -v '^*deleting'
echo
echo "Press CTRL-C to continue"
