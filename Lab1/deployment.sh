#!/bin/bash

az login

# todo read project name

az group create --name \
    --$resourceGroupName \
    --location westeurope # todo optional location read from config

