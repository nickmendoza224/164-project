# 164-project
# Pi-hole DNS Blocking and Machine Learning Analysis

## Project Overview
This project analyzes DNS-based ad blocking using a Docker-based Pi-hole resolver. DNS traffic was collected from repeated experiment runs using common websites and advertising domains. The collected data was processed with Python, stored in Neon PostgreSQL, and evaluated using supervised machine learning models from scikit-learn.

## Datasets
This project uses two main datasets:

1. DNS Run Summary Dataset  
   Each row represents a domain tested during a specific experiment run. Features include DNS response time, packet size, response count, and DNS answer behavior. The target variable is `blocked`, which indicates whether Pi-hole blocked the domain.

2. DNS Packet Capture Dataset  
   This dataset contains packet-level DNS traffic extracted from PCAP files using tshark. Features include source and destination IPs, ports, DNS fields, packet size, and resolver path.

A third hop-results dataset was also collected using tracepath to observe route variation across tested domains.

## Models
The project compares three supervised learning models:

- Logistic Regression
- k-Nearest Neighbors
- Random Forest

## Current Results
For the DNS summary dataset, Logistic Regression achieved 80% accuracy, while k-Nearest Neighbors and Random Forest achieved 100% accuracy on the test split. These results show that DNS timing, packet size, and response behavior can help distinguish blocked and allowed domains in a controlled Pi-hole experiment.

## Tools Used
Python, pandas, scikit-learn, Google Colab, Neon PostgreSQL, Docker, Pi-hole, tcpdump, tshark, dig, tracepath, Bash, and GitHub.

## Repository Contents
- `collect_data.sh`: Bash script used to collect DNS packet data
- `csv.zip`: Processed DNS CSV files
- `hops.zip`: Tracepath hop result files
- `logs.zip`: Experiment logs
- `pihole setup.zip`: Pi-hole setup files
- `notebooks/`: Final Colab/Jupyter notebook
