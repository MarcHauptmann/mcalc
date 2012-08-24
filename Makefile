test:
	for file in `ls *.t`; do \
		echo " - teste $$file - "; \
		perl $$file; \
	done 