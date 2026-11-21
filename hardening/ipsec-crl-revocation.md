# IPsec certificate revocation (finding A-05)

**Status:** proposed, not validated in the lab. OpenVPN revocation is already tested (`T2-11` to `T2-13`).

## Plan (strongSwan, swanctl)

1. Copy the CA's current CRL (the one used by OpenVPN) to both gateways:
   ```bash
   sudo cp /etc/openvpn/crl/crl.pem /etc/swanctl/x509crl/securelink-ca.crl.pem
   ```
2. In the `hq-branch` connection, set revocation to strict on the remote authentication block:
   ```
   remote {
       auth = pubkey
       revocation = strict
   }
   ```
3. Reload and re-establish the tunnel:
   ```bash
   sudo swanctl --load-all && sudo swanctl --initiate --child hq-branch
   ```
4. **Test:** revoke the `gw-branch` certificate on the CA, regenerate and copy the CRL, then re-initiate. Expected result: IKE authentication fails with a revoked-certificate error. Reinstate with a newly issued certificate.

## Operational notes
- `strict` rejects every peer once the CRL expires (the lab CRL is valid to 25 April 2027), so schedule a CRL refresh and monitor its expiry date.
- Add a cron job or config-management task to push new CRLs to both gateways.
