#!/bin/bash

# ==============================
# Pi-hole DNS Data Collection Script
# ==============================

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create organized output folders
BASE_DIR="data"
PCAP_DIR="$BASE_DIR/pcaps"
CSV_DIR="$BASE_DIR/csv"
HOP_DIR="$BASE_DIR/hops"
LOG_DIR="$BASE_DIR/logs"

mkdir -p "$PCAP_DIR" "$CSV_DIR" "$HOP_DIR" "$LOG_DIR"

# Output files
PCAP_FILE="$PCAP_DIR/dns_capture_$TIMESTAMP.pcap"
CSV_FILE="$CSV_DIR/dns_capture_$TIMESTAMP.csv"
HOP_FILE="$HOP_DIR/hop_results_$TIMESTAMP.txt"
LOG_FILE="$LOG_DIR/experiment_log.txt"

DNS_SERVER="127.0.0.1"
DNS_PORT="5300"

SITES=(
"youtube.com"
"google.com"
"facebook.com"
"reddit.com"
"amazon.com"
"netflix.com"
"twitter.com"
"instagram.com"
"yahoo.com"
"wikipedia.org"
"doubleclick.net"
"ads.google.com"
)

echo "======================================"
echo "Starting Pi-hole DNS Data Collection"
echo "Timestamp: $TIMESTAMP"
echo "PCAP File: $PCAP_FILE"
echo "CSV File: $CSV_FILE"
echo "Hop File: $HOP_FILE"
echo "Log File: $LOG_FILE"
echo "======================================"

echo "RUN | $TIMESTAMP | $PCAP_FILE | $CSV_FILE | $HOP_FILE" >> "$LOG_FILE"

echo "[1] Starting tcpdump capture..."
sudo tcpdump -i any '(port 53 or port 5300)' -w "$PCAP_FILE" &
TCPDUMP_PID=$!

sleep 2

echo "[2] Running DNS queries..."
for site in "${SITES[@]}"
do
    echo "Querying $site"
    timeout 8 dig @"$DNS_SERVER" -p "$DNS_PORT" "$site"
    sleep 1
done

echo "[3] Running hop tests..."
echo "Hop Test Run: $TIMESTAMP" > "$HOP_FILE"
echo "======================================" >> "$HOP_FILE"

for site in "${SITES[@]}"
do
    echo "Testing hops for $site"
    echo "" >> "$HOP_FILE"
    echo "Website: $site" >> "$HOP_FILE"

    timeout 10 tracepath -4 "$site" >> "$HOP_FILE" 2>&1

    if [ $? -eq 124 ]; then
        echo "Hop test timed out after 10 seconds" >> "$HOP_FILE"
    fi

    echo "--------------------------------------" >> "$HOP_FILE"
    sleep 1
done

echo "[4] Stopping tcpdump..."
sudo kill "$TCPDUMP_PID" 2>/dev/null

sleep 2

echo "[5] Converting PCAP to CSV..."
tshark -r "$PCAP_FILE" -d udp.port==5300,dns -d tcp.port==5300,dns -T fields \
-e frame.number \
-e frame.time \
-e ip.src \
-e ip.dst \
-e ipv6.src \
-e ipv6.dst \
-e udp.srcport \
-e udp.dstport \
-e tcp.srcport \
-e tcp.dstport \
-e dns.flags.response \
-e dns.qry.name \
-e dns.qry.type \
-e dns.resp.type \
-e dns.flags.rcode \
-e dns.time \
-e dns.a \
-e dns.aaaa \
-e frame.len \
-e udp.length \
-e tcp.len \
-E header=y \
-E separator=, \
-E quote=d \
> "$CSV_FILE"

echo "======================================"
echo "Data collection complete."
echo "Saved PCAP: $PCAP_FILE"
echo "Saved CSV: $CSV_FILE"
echo "Saved hop results: $HOP_FILE"
echo "Logged run in: $LOG_FILE"
echo "======================================"
