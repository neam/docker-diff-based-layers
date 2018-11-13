FROM ${OLD_IMAGE}
ADD files-to-add.tar /
ADD files-to-remove.list /.files-to-remove.list
RUN if [ -s /.files-to-remove.list ]; then xargs -d '\n' -a /.files-to-remove.list rm; fi; rm /.files-to-remove.list;
