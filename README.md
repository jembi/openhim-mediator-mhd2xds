MHD2XDS Mediator
================

This is a mediator for the [OpenHIM](http://www.openhim.org) tool that converts IHE MHD messages to XDS.b messages. Right now it only support a specific simplified MHDv1 format and the provider and register transaction that we have been using for internal projects, however the plan is to expand this mediator to support MHDv2 (FHIR-based) messgages generically.

To run, clone the repo and run `npm start`

To install as a binary, clone the repo and run `npm install -g .` then run the binary `mhd2xds`.

## Send a test message

From the test/ directory execute the following (just replace the auth and host details):

```
curl -X POST -H "Content-Type: multipart/form-data; boundary=48940923NODERESLTER3890457293" -H "Expect:" -H "Authorization: Basic <base64_auth>" --data-binary @generated-mhd.txt -v http://<host>:5001/mhd/
```