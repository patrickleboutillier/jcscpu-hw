
clean:
	rm -f tb/out/* out/*

test: clean
	./tb/tools/gentests.sh
	./tb/tools/buildtests.sh
	./tb/tools/runtests.sh

demo: 
	for e in examples/* ; do echo $$e ; ./jcscpu.sh $$e ; done
