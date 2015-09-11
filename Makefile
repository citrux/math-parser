SOURCE := main.d lexer.d container.d ast.d
OBJS := $(patsubst %.d, %.o, $(SOURCE))

default: gdc

dmd: $(SOURCE)
	dmd -gc $(SOURCE)

gdc: $(SOURCE)
	gdc -g -o main $(SOURCE)

ldc: $(SOURCE)
	ldc -gc -of=main $(SOURCE)

clean:
	rm -f main $(OBJS)
