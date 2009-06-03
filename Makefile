CC      = gcc
CFLAGS  = -Wall -m32
LDFLAGS = -framework Foundation
PROGRAM = test
OBJS    = NSDate+W3CDTFSupport.o test.o

$(PROGRAM): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(PROGRAM) $(OBJS)
W3CDTF.o: NSDate+W3CDTFSupport.m
	$(CC) $(CFLAGS) -c $<
test.o: test.m
	$(CC) $(CFLAGS) -c $<
clean:
	rm $(PROGRAM) $(OBJS)
