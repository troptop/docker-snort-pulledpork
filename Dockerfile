# Snort in Docker
FROM ubuntu:14.04.4

MAINTAINER John Lin <linton.tw@gmail.com>

RUN apt-get update && \
    apt-get install -y \
        wget \
        build-essential \
        # Pre-requisites for Snort DAQ (Data AcQuisition library)
        bison \
        flex \
        # Pre-Requisites for snort
        libpcap-dev \
        libpcre3-dev \
        libdumbnet-dev \
        # Additional required pre-requisite for Snort
        zlib1g-dev \
        # Optional libraries that improves fuctionality
        liblzma-dev \
        openssl \
        libssl-dev libcrypt-ssleay-perl liblwp-useragent-determined-perl git vim && \
    rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /opt

ENV DAQ_VERSION 2.0.6
RUN wget https://www.snort.org/downloads/snort/daq-${DAQ_VERSION}.tar.gz \
    && tar xvfz daq-${DAQ_VERSION}.tar.gz \
    && cd daq-${DAQ_VERSION} \
    && ./configure; make; make install

ENV SNORT_VERSION 2.9.11.1
RUN wget https://www.snort.org/downloads/snort/snort-${SNORT_VERSION}.tar.gz \
    && tar xvfz snort-${SNORT_VERSION}.tar.gz \
    && cd snort-${SNORT_VERSION} \
    && ./configure --enable-sourcefire --enable-perfprofiling --enable-linux-smp-stats --enable-gre  --enable-targetbased --enable-mpls \
    &&  make && make install

RUN ldconfig

# ENV SNORT_RULES_SNAPSHOT 2972
# ADD snortrules-snapshot-${SNORT_RULES_SNAPSHOT} /opt
RUN mkdir -p /opt/snort
RUN mkdir -p /opt/pulledpork
ADD mysnortrules /opt/snort
ADD mypulledpork /opt/pulledpork
RUN mkdir -p /var/log/snort && \
    mkdir -p /usr/local/lib/snort_dynamicrules && \
    mkdir -p /etc/snort && \
    mkdir -p /etc/pulledpork && \
    # mysnortrules rules
    cp -r /opt/snort/* /etc/snort/ 

RUN cp -r /opt/pulledpork/* /etc/pulledpork && \
	/usr/bin/chmod +x /etc/pulledpork/pulledpork.pl && /usr/bin/ln -s /etc/pulledpork/pulledpork.pl /usr/local/bin/pulledpork.pl && \
    echo '01 04 * * * /usr/local/bin/pulledpork.pl -c /etc/pulledpork/pulledpork.conf -l' >> /etc/crontab && \
    restart cron
# Clean up APT when done.
RUN apt-get clean && rm -rf /tmp/* /var/tmp/* \
    /opt/snort-${SNORT_VERSION}.tar.gz /opt/daq-${DAQ_VERSION}.tar.gz

# Validate an installation
CMD ["snort", "-V"]
