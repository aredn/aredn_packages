ssidident: ssidident.c
	$(CC) $(CFLAGS) $(LDFLAGS) radiotap.c ssidident.c -o ssidident -lpcap

clean:
	rm -f ssidident *~

install:
	mkdir -p $(DESTDIR)/usr/bin
	cp ssidident $(DESTDIR)/usr/bin

style:
	cstyle packetspammer.c radiotap.c
