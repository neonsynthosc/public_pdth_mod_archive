.PHONY: all

MOD_NAME := zneixs_fixes

all: clean publish

clean:
	rm -rf *.zip $(MOD_NAME)

publish: clean
	mkdir $(MOD_NAME) && \
	cp *.lua $(MOD_NAME) && \
	zip $(MOD_NAME).zip -r $(MOD_NAME) \

push: publish
	rsync -aP $(MOD_NAME).zip dank:~/cdn/pdthmods/downloads/
