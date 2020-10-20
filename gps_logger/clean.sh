#!/bin/bash

rm -rf ./data/*.* > /dev/null && echo "Deleted files in data dir." || echo "No files in the data directory!"
rm -rf ./logs/*.* > /dev/null && echo "Deleted all log files." || echo "No log files to delete!"