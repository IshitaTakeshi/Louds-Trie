DCC = dmd
DFLAGS = -w -g -debug -O -release -noboundscheck -profile -D -unittest

SRC = test.d louds.d queue.d lib/array.d

TARGET = test

OBJS = $(SRC:.d=.o)

all:
	$(DCC) $(SRC) $(DFLAGS)

run:
	./$(TARGET)

clean:
	-@$(RM) $(OBJS) $(TARGET)
