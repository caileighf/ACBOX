#!/bin/bash

gpspipe -n 4 -w | grep 'TPV' | grep -oE 'mode\":0,|mode\":1,' > /dev/null && echo 'GPS HAS NO FIX' || echo 'GPS HAS FIX'