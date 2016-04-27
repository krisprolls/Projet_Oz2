all: run 
ARGS = -l 3

bin:
	mkdir -p bin
	
compile: bin 
	ozc -c src/PacMan.oz -o bin/PacMan.ozf
	ozc -c src/PacManGUI.oz -o bin/PacManGUI.ozf
	
run: compile 
	ozengine bin/PacMan.ozf $(ARGS)

clean:
	rm -rf bin
	
mrproper: clean
