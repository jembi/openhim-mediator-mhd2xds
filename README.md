MHD2XDS Mediator
================

This is a mediator for the [OpenHIM](http://www.openhim.org) tool that converts IHE MHD messages to XDS.b messages. Right now it only support a specific simplified MHDv1 format and the provider and register transaction that we have been using for internal projects, however the plan is to expand this mediator to support MHDv2 (FHIR-based) messgages generically.

To run, clone the repo and run `npm start`

To install as a binary, clone the repo and run `npm install -g .` then run the binary `mhd2xds`.
