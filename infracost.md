
<h4>💰 Infracost report</h4>
<h4>Monthly estimate increased by $100 📈</h4>
<table>
  <thead>
    <td>Changed project</td>
    <td><span title="Baseline costs are consistent charges for provisioned resources, like the hourly cost for a virtual machine, which stays constant no matter how much it is used. Infracost estimates these resources assuming they are used for the whole month (730 hours).">Baseline cost</span></td>
    <td><span title="Usage costs are charges based on actual usage, like the storage cost for an object storage bucket. Infracost estimates these resources using the monthly usage values in the usage-file.">Usage cost</span>*</td>
    <td>Total change</td>
    <td>New monthly cost</td>
  </thead>
  <tbody>
    <tr>
      <td>SebPikPik/aws-bikininjas-infra/tfplan</td>
      <td align="right">+$100</td>
      <td align="right">-</td>
      <td align="right">+$100</td>
      <td align="right">$100</td>
    </tr>
  </tbody>
</table>


*Usage costs can be estimated by updating [Infracost Cloud settings](https://www.infracost.io/docs/features/usage_based_resources), see [docs](https://www.infracost.io/docs/features/usage_based_resources/#infracost-usageyml) for other options.
<details>

<summary>Estimate details </summary>

```
Key: * usage cost, ~ changed, + added, - removed

──────────────────────────────────
Project: SebPikPik/aws-bikininjas-infra/tfplan

+ module.ecs.aws_ecs_service.minecraft
  +$43

    + Per GB per hour
      +$8

    + Per vCPU per hour
      +$35

+ module.networking.aws_nat_gateway.main
  +$37

    + NAT gateway
      +$37

    + Data processed
      Monthly cost depends on usage
        +$0.05 per GB

+ module.ecs.aws_lb.minecraft
  +$19

    + Network load balancer
      +$19

    + Load balancer capacity units
      Monthly cost depends on usage
        +$4.60 per LCU

+ module.dns.aws_route53_zone.main
  +$0.50

    + Hosted zone
      +$0.50

+ module.dns.aws_route53_record.cert_validation["mc.bikininja.click"]
  Monthly cost depends on usage

    + Standard queries (first 1B)
      Monthly cost depends on usage
        +$0.40 per 1M queries

    + Latency based routing queries (first 1B)
      Monthly cost depends on usage
        +$0.60 per 1M queries

    + Geo DNS queries (first 1B)
      Monthly cost depends on usage
        +$0.70 per 1M queries

+ module.dns.aws_route53_record.minecraft
  Monthly cost depends on usage

    + Standard queries (first 1B)
      Monthly cost depends on usage
        +$0.40 per 1M queries

    + Latency based routing queries (first 1B)
      Monthly cost depends on usage
        +$0.60 per 1M queries

    + Geo DNS queries (first 1B)
      Monthly cost depends on usage
        +$0.70 per 1M queries

+ module.ecr.aws_ecr_repository.minecraft
  Monthly cost depends on usage

    + Storage
      Monthly cost depends on usage
        +$0.10 per GB

+ module.ecs.aws_cloudwatch_log_group.minecraft
  Monthly cost depends on usage

    + Data ingested
      Monthly cost depends on usage
        +$0.60 per GB

    + Archival Storage
      Monthly cost depends on usage
        +$0.0315 per GB

    + Insights queries data scanned
      Monthly cost depends on usage
        +$0.0059 per GB

+ module.storage.aws_efs_file_system.minecraft
  Monthly cost depends on usage

    + Storage (standard)
      Monthly cost depends on usage
        +$0.33 per GB

    + Storage (standard, infrequent access)
      Monthly cost depends on usage
        +$0.0261 per GB

    + Read requests (infrequent access)
      Monthly cost depends on usage
        +$0.011 per GB

    + Write requests (infrequent access)
      Monthly cost depends on usage
        +$0.011 per GB

Monthly cost change for SebPikPik/aws-bikininjas-infra/tfplan
Amount:  +$100 ($0.00 → $100)

──────────────────────────────────
Key: * usage cost, ~ changed, + added, - removed

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

39 cloud resources were detected:
∙ 9 were estimated
∙ 30 were free

Infracost estimate: Monthly estimate increased by $100 ↑
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Changed project                                    ┃ Baseline cost ┃ Usage cost* ┃ Total change ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ SebPikPik/aws-bikininjas-infra/tfplan              ┃         +$100 ┃           - ┃        +$100 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```
</details>
