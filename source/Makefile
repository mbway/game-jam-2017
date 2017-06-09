.PHONY: tags lint run
.PHONY: always-rebuild

run:
	love . | tee last-run.log

tags: always-rebuild
	ctags -R --extra=+q --languages=lua

lint:
	luacheck .
