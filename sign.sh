#!/bin/bash

sbsign --key MOK.priv --cert MOK.pem $1 --output $2
