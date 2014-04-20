/// (c)2013-2015 Conrad Lara <kg6jei@amsat.org>

/*
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; version 2.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License along
 *   with this program; if not, write to the Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

// Based on the Andy Green <andy@warmcat.com> packetspammer application (C)2007

#include "packetspammer.h"
#include "radiotap.h"


/* this is the template radiotap header we send packets out with */

static const u8 u8aRadiotapHeader[] = {

	0x00, 0x00, // <-- radiotap version
	0x19, 0x00, // <- radiotap header length
	0x6f, 0x08, 0x00, 0x00, // <-- bitmap
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // <-- timestamp
	0x00, // <-- flags (Offset +0x10)
	0x6c, // <-- rate (0ffset +0x11)
	0x71, 0x09, 0xc0, 0x00, // <-- channel
	0xde, // <-- antsignal
	0x00, // <-- antnoise
	0x01, // <-- antenna

};

/* Penumbra IEEE80211 header */

/* Header Format 
 * Header
 * Destination Mac
 * source mac
 * BSS ID
 * Fragment,sqeuence
 */
static const u8 u8aIeeeHeader[] = {
	0x80, 0x00, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
	0x00, 0x00,
};

static const u8 u8BeaconHeader[] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Timestamp
        0x64, 0x00,					// Beacon Interval
	0x02, 0x00,					// Capabilities 
        0x00,						// SSID is next -- DO NOT ADD ANYTHING AFTER THIS
};

static const u8 u8BeaconFooter[] = {
        0x01, 0x08, 0x82, 0x84, 0x8b, 0x96, 0x24, 0x30, 0x48, 0x6c, // Tag Number 1: Supported Rates
        0x06, 0x02, 0x00, 0x00,                                     // Tag Number 6: ATIM Window 
};

// this is where we store a summary of the
// information from the radiotap header

typedef struct  {
	int m_nChannel;
	int m_nChannelFlags;
	int m_nRate;
	int m_nAntenna;
	int m_nRadiotapFlags;
} __attribute__((packed)) PENUMBRA_RADIOTAP_DATA;



int flagHelp = 0, flagMarkWithFCS = 0;

void
usage(void)
{
	printf(
	    "\n");
	exit(1);
}


int
main(int argc, char *argv[])
{
	u8 u8aSendBuffer[500];
	char szErrbuf[PCAP_ERRBUF_SIZE];
	int nLinkEncap = 0;
	int nOrdinal = 0, r, nDelay = 100000;
	int nRateIndex = 0, retval, bytes;
	pcap_t *ppcap = NULL;
	struct bpf_program bpfprogram;
	char * szProgram = "", fBrokenSocket = 0;
	u16 u16HeaderLen;
	char szHostname[PATH_MAX];
        char ssidHostname[33]; // 32char limit for SSID +1

        if (gethostname(szHostname, sizeof (szHostname) - 1)) {
                perror("unable to get hostname");
                return (1);
        }

        szHostname[sizeof (szHostname) - 1] = '\0';

        if (strlen(szHostname) <= 32) {
                // Copy value direct
                memcpy(ssidHostname,szHostname,strlen(szHostname)+1);
        } else {
                // Truncate the hostname to fit ssid length.
                memcpy(ssidHostname,szHostname,32);
                ssidHostname[32] = '\0'; // Terminate the string for later use.
        }

	printf("BBHN Unit Announcer (c)2013-2014 Conrad Lara -- KG6JEI <KG6JEI@amsat.org> GPLv2\n");
	printf("Announcing as %s\n",ssidHostname);

	szErrbuf[0] = '\0';
	ppcap = pcap_open_live(argv[optind], 800, 1, 20, szErrbuf);

	if (ppcap == NULL) {
		printf("Unable to open interface %s in pcap: %s\n",
		    argv[optind], szErrbuf);
		return (1);
	}

	nLinkEncap = pcap_datalink(ppcap);

	switch (nLinkEncap) {

		case DLT_PRISM_HEADER:
			break;

		case DLT_IEEE802_11_RADIO:
			break;

		default:
			printf("!!! unknown encapsulation on %s ! Please make sure you are using a wireless port and it is in monitor mode.\n", argv[1]);
			return (1);

	}

	if (pcap_compile(ppcap, &bpfprogram, szProgram, 1, 0) == -1) {
		puts(szProgram);
		puts(pcap_geterr(ppcap));
		return (1);
	} else {
		if (pcap_setfilter(ppcap, &bpfprogram) == -1) {
			puts(szProgram);
			puts(pcap_geterr(ppcap));
		} else {
			//printf("RX Filter applied\n");
		}
		pcap_freecode(&bpfprogram);
	}

	pcap_setnonblock(ppcap, 1, szErrbuf);

	memset(u8aSendBuffer, 0, sizeof (u8aSendBuffer));

	while (!fBrokenSocket) {
		u8 * pu8 = u8aSendBuffer;
		struct pcap_pkthdr * ppcapPacketHeader = NULL;
		struct ieee80211_radiotap_iterator rti;
//		PENUMBRA_RADIOTAP_DATA prd;
		u8 * pu8Payload = u8aSendBuffer;
		int n, nRate;

		// receive

		retval = pcap_next_ex(ppcap, &ppcapPacketHeader,
		    (const u_char**)&pu8Payload);

		if (retval < 0) {
			fBrokenSocket = 1;
			continue;
		}

		if (retval != 1) {
		// transmit

			memcpy(u8aSendBuffer, u8aRadiotapHeader,
				sizeof (u8aRadiotapHeader));
			pu8 += sizeof (u8aRadiotapHeader);

			memcpy(pu8, u8aIeeeHeader, sizeof (u8aIeeeHeader));
			pu8 += sizeof (u8aIeeeHeader);

                        memcpy(pu8, u8BeaconHeader, sizeof (u8BeaconHeader));
                        pu8 += sizeof (u8BeaconHeader);

			pu8 += sprintf((char *)pu8,
                            "%c%s",
		            strlen(ssidHostname), ssidHostname);

                        memcpy(pu8,u8BeaconFooter, sizeof (u8BeaconFooter));
                        pu8 += sizeof (u8BeaconFooter);

			r = pcap_inject(ppcap, u8aSendBuffer, pu8 - u8aSendBuffer);
			if (r != (pu8-u8aSendBuffer)) {
				perror("Trouble injecting packet");
				return (1);
			}
			usleep(500000); // Limits us to around 2 packets per second.
		}

	}

	return (0);
}
