FROM ${OLD_IMAGE}
ADD files-to-add.tar /
ADD files-to-remove.list /.files-to-remove.list
RUN xargs -d '\n' -a /.files-to-remove.list rm && rm /.files-to-remove.list
